class MainController < ApplicationController
  layout :check_layout
  skip_before_filter :context_data ,:only => [:advertisement, :clickthrough]
  before_filter :find_contact, :only => [:contact, :quote, :quote_bandwidth, :quote_colocation, :quote_equipment, :quote_managed_services, :quote_send]

  def contact
    @title ||= 'Contact Us'
  end

  def contact_send
    if @contact.update_attributes(params[:contact].update({:details => params[:details], :referer => session[:referer]}))
      flash[:notice] = 'Your request has been sent'
      return redirect_to(contact_sent_path)
    end
    flash[:error] = 'Your request could not be sent'
    flash[:error_list] = @contact.error_list
    render :contact
  end

  def contact_sent
    return deny unless flash[:notice] == 'Your request has been sent'
    @title ||= 'Contact Request Sent'
  end

  def data_center
    return deny unless params[:id] && response = FindADataCenter.get("data-centers/#{params[:id]}")
    if response['error']
      @title = 'Error!'
      flash[:error] = response['error']
    elsif @data_center = response['data_center']
      if params[:quote] == 'yes'
        session[:data_centers] ||= []
        session[:data_centers].push(@data_center) unless session[:data_centers].include?(@data_center)
        return redirect_to(colocation_quote_path)
      end
      @title = @data_center['name']
    else
      return deny
    end
  end

  def data_center_search
    if request.post?
      if response = FindADataCenter.post(:search, params)
        if response['error']
          flash[:error] = response['error']
        elsif response['data_centers'] && response['data_centers'].length > 0
          @data_centers = response['data_centers']
        end
      end
      flash[:error] = 'No data centers were returned' unless @data_centers
    end
    @title ||= 'Search Data Centers'
    respond_to do |format|
      format.json { render :json => {:data_centers => @data_centers || []} }
      format.html { render :action => @data_centers ? :data_center_search_results : :data_center_search }
    end
  end

  def index
  end

  def quote
    @title ||= 'Get a Quote'
    if params[:state] && params[:city]
      params[:city].gsub!('+', ' ')
      if market = MARKETS.select{|market| market[:city] == params[:city] && market[:state] == params[:state]}.first
        session[:location] = market
        @title << " &raquo; #{market[:city]}, #{market[:state]}"
      else
        return deny
      end
    end
  end

  def quote_bandwidth
    @addresses ||= []
    @quote = BandwidthQuote.new(:product => BandwidthQuote::Product.options.first[1])
    @title ||= 'Get a Quote &raquo; Bandwidth'
  end

  def quote_colocation
    @data_centers = session[:data_centers]
    @quote = ColocationQuote.new
    @title ||= 'Get a Quote &raquo; Colocation'
  end

  def quote_equipment
    @quote = EquipmentQuote.new
    @title ||= 'Get a Quote &raquo; Equipment'
  end

  def quote_managed_services
    @quote = ManagedServicesQuote.new
    @title ||= 'Get a Quote &raquo; Managed Services'
  end

  def quote_send
    @quote = params[:quote][:type].constantize.new(params[:quote])
    if existing_contact = Contact.find_by_email(params[:contact][:email])
      @contact = existing_contact
    end
    # Stupid security bug, but it's the quickest way to a single method
    return deny unless @quote.is_a?(Quote)
    @quote.type = params[:quote][:type]
    @contact.update_attributes(params[:contact])
    if @quote.valid? && @contact.valid? && @quote.save && @contact.save
      session[:data_centers] = nil
      session[:location] = nil
      session[:contact_id] = @contact.id
      flash[:notice] = 'Thank you for submitting your quote! Someone will reply to you shortly.'
      return redirect_to(quote_sent_path)
    end
    flash[:error] = 'This quote could not be saved'
    render :action => "quote_#{@quote.type.tableize.gsub('_quotes', '')}"
  end

  def quote_sent
    return deny unless flash[:notice]
  end

  def search
    Article.send(:acts_as_sphinx)
    Page.send(:acts_as_sphinx)
    @bodytitle ||= "Search"
    @title ||= "Search"
    unless params[:q].blank?
      @title << " Results: #{params[:q].shorten(20)}"
      if page = Page.find(:first,:conditions => ["pages.attached = ? AND pages.controller = ? AND pages.action = ?",true,"main","data_center"])
        parent_id = page.id
      else
        parent_id = -1
      end
      articles = Article.find_with_sphinx(params[:q],:conditions => ["articles.publish_date <= ?",Date.today],:sort_mode => :relevance)
      pages = Page.find_with_sphinx(params[:q],:conditions => ["pages.active = ? AND (pages.parent_id IS NULL OR pages.parent_id != ?)",true,parent_id],:sort_mode => :sort_mode)
      raise articles.first.inspect
      @results = [articles,pages].flatten.sort{|a,b| a.relevance <=> b.relevance}.paginate(:page => params[:page],:per_page => 10)
    end
  end

  protected
  def build_advertisement
    # @advertisement_top = AdvertisementDisplay.new(:height => 159,:width => 685)
  end

  def check_layout
    params[:external] == 'yes' ? 'external' : 'application'
  end

  def find_contact
    @contact = Contact.find(session[:contact_id]) if session[:contact_id]
    @contact ||= Contact.new(:subscriber => true)
  end
end