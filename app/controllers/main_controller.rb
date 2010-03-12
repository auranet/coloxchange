class MainController < ApplicationController
  layout :check_layout
  skip_before_filter :context_data ,:only => [:advertisement, :clickthrough]
  before_filter :find_contact, :only => [:contact, :contact_send, :quote, :quote_bandwidth, :quote_colocation, :quote_equipment, :quote_managed_services, :quote_send]
  caches_page :data_center

  def contact
    @title ||= 'Contact Us'
  end

  def contact_send
    return deny if params[:website] != 'http://'
    if save_contact
      session[:contact_id] = @contact.id
      flash[:notice] = 'Your request has been sent'
      return redirect_to(contact_sent_path)
    end
    @page = Page.find_by_action('contact')
    flash[:error] = 'Your request could not be sent'
    render :action => :contact
  end

  def contact_sent
    return deny unless flash[:notice] == 'Your request has been sent'
    @title ||= 'Contact Request Sent'
  end

  def data_center
    session[:data_centers] = {params[:data_center][:slug] => params[:data_center]}
    redirect_to colocation_quote_path
    return
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
          flash[:error] = response['error'] unless request.xhr?
        elsif response['data_centers'] && response['data_centers'].length > 0
          @data_centers = response['data_centers']
        end
      end
      flash[:error] = 'No data centers were returned' if !request.xhr? && (!@data_centers || @data_centers.empty?)
    end
    @title ||= 'Search Data Centers'
    respond_to do |format|
      format.html { render :action => @data_centers ? :data_center_search_results : :data_center_search }
      format.json { render :json => {:data_centers => @data_centers || []} }
    end
  end

  def index
    @news_items = NewsItem.find(:all, :limit => 5, :order => 'news_items.date DESC, news_items.id DESC')
  end

  def quote
    @title ||= 'Get a Quote'
  end

  def quote_bandwidth
    @addresses ||= []
    @quote = BandwidthQuote.new(:product => BandwidthQuote::Product.options.first[1])
    @title ||= 'Get a Quote &raquo; Bandwidth'
  end

  def quote_colocation
    @quote = ColocationQuote.new(:target_date => 1.month.from_now)
    @title ||= 'Get a Quote &raquo; Colocation'
    if params[:state] && params[:city]
      params[:city].gsub!('+', ' ')
      if market = MARKETS.select{|market| market[:city] == params[:city] && market[:state] == params[:state]}.first
        # session[:location] = market
        @location = "#{market[:city]}, #{market[:state]}"
        @title << " &raquo; #{market[:city]}, #{market[:state]}"
      else
        return deny
      end
    elsif params[:data_center]
    end
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
    # Stupid security hack, but it's the quickest way to a single method w/updating multiple classes
    return deny unless @quote.is_a?(Quote)
    @quote.type = params[:quote][:type]
    save_contact
    session[:contact_id] = @contact.id
    @quote.contact = @contact
    if @quote.valid? && @contact.valid? && @quote.save && @contact.save
      session[:data_centers] = nil
      session[:location] = nil
      flash[:notice] = 'Thank you for submitting your quote request!'
      flash[:quote_type] = @quote.type.to_s.tableize
      return redirect_to(quote_sent_path)
    end
    session[:data_centers] = params[:quote][:data_centers].select{|slug, data_center| data_center['include'] == 'true' } if params[:quote][:data_centers]
    flash[:error] = 'This quote could not be saved'
    render :action => "quote_#{@quote.type.tableize.gsub('_quotes', '')}"
  end

  def quote_sent
    return deny unless flash[:notice]
  end

  def search
    @bodytitle ||= "Search"
    @title ||= "Search"
    unless params[:q].blank?
      @title << " Results: #{params[:q].shorten(20)}"
      @results = Page.search(params[:q], :page => params[:page], :per_page => 10)
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
    @contact = Contact.find_by_id(session[:contact_id]) if session[:contact_id]
    @contact ||= Contact.new(:subscriber => true)
  end

  def save_contact
    @contact.update_attributes(params[:contact].merge(:contact_request => true, :referring_site => @contact.referring_site || session[:referer]))
  end
end
