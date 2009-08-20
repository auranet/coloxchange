class MainController < ApplicationController
  before_filter :find_page,:except => [:advertisement,:clickthrough]
  before_filter :require_admin,:only => :page_preview
  caches_page :article,:newsletter,:page,:sitemap
  skip_before_filter :load_context_data,:context_data,:only => [:advertisement,:clickthrough]

  def advertisement
    conditions = {:active => true,:ends_on__gte => Date.today,:height => params[:height],:width => params[:width]}
    queryset = Advertisement.filter(conditions)
    default = true
    if params[:lat] && params[:lng]
      queryset.filter(:advertisement_regions__sw_lat__lte => params[:lat],:advertisement_regions__sw_lng__lte => params[:lng],:advertisement_regions__ne_lat__gte => params[:lat],:advertisement_regions__ne_lng__gte => params[:lng],:regional => true)
      default = queryset.empty?
    end
    queryset = Advertisement.filter(conditions.merge(:regional => false)) if default
    if @advertisement = queryset.find(:first,:order => "RAND()")
      @advertisement.impressions.create
    else
      @advertisement = Advertisement.new(:height => params[:height],:force_url => url_for(:controller => "main",:action => "advertise"),:width => params[:width])
    end
    render :text => "<html><head><title></title><style type=\"text/css\">body { margin:0; padding:0;} a img { border-width:0; }</style></head><body style=\"margin:0;padding:0;\"><a href=\"#{@advertisement.force_url ? @advertisement.force_url : url_for(:action => "clickthrough",:id => @advertisement.uniq_id)}\" rel=\"nofollow\" target=\"_new\">#{@advertisement}</a></body></html>"
  end

  def article
    return deny unless params[:id] && @article = Article.find(:first,:conditions => ["articles.slug = ? AND articles.publish_date <= ?",params[:id],DateTime.now])
    @title = @article.name
  end

  def articles
    if params[:user_id] && user = User.find(:first,:conditions => ["users.active = ? AND users.id =?",true,params[:user_id]],:include => [{:articles => :user}])
      @title = "#{user.name.possessive} Articles"
      @articles = user.articles.paginate(:conditions => ["articles.publish_date <= ?",DateTime.now],:include => [:user],:order => "articles.publish_date DESC",:page => params[:page],:per_page => CMS.articles_per_page)
      return deny if @articles.empty?
    elsif params[:category_id] && category = Category.find(:first,:conditions => ["name_based_models.slug = ?",params[:category_id]])
      @title ||= "Articles &aquo; #{category.name}"
      @articles = category.articles.paginate(:conditions => ["articles.publish_date <= ?",DateTime.now],:include => [:user],:order => "articles.publish_date DESC",:page => params[:page],:per_page => CMS.articles_per_page)
      return deny if @articles.empty?
    elsif !params[:id]
      @title ||= "Article Directory"
      @articles = Article.paginate(:conditions => ["articles.publish_date <= ?",DateTime.now],:include => [:user],:order => "articles.publish_date DESC",:page => params[:page],:per_page => CMS.articles_per_page)
    else
      return deny
    end
  end

  def clickthrough
    return deny unless params[:id] && @advertisement = Advertisement.find(:first,:conditions => ["advertisements.uniq_id = ?",params[:id]])
    click(@advertisement)
    redirect_to @advertisement.url
  end

  def news
    @title ||= "#{site_name} News"
    @news_items = NewsItem.paginate(:order => "news_items.date DESC,news_items.id DESC",:page => params[:page],:per_page => CMS.news_items_per_page)
  end

  def news_item
    return deny unless @news_item = NewsItem.find(:first,:conditions => ["news_items.slug = ? AND news_items.kind != ?",params[:id],"Press Release"])
    @title = @news_item.name
  end

  def newsletter
    if @newsletter = Newsletter.find(:first,:conditions => ["newsletters.sent = ?",true],:order => "date DESC")
      @title = "Newsletter: #{@newsletter.date.strftime("%B %Y")}"
    else
      @title ||= "Newsletter"
      render :text => "Sorry, there is no current newsletter. Please check back soon.",:layout => true
    end
  end

  def newsletter_signup
    if request.post?
      newsletter_user = User.find_or_initialize_by_email(params[:email])
      user_hash = {:subscriber => true}
      user_hash = user_hash.update({:authenticates => false,:active => false}) if newsletter_user.new_record?
      if newsletter_user.update_attributes(user_hash.update({:name => params[:name]}))
        @title = "Subscription complete"
        flash[:notice] = "Thanks for signing up for our newsletter!"
        render :text => "You will begin receiving our newsletter immediately at #{newsletter_user.email}. Thanks for subscribing!",:layout => true and return
      else
        @title = "Your subscription could not be processed"
        flash[:error] = "You could not be added to the newsletter"
        flash[:error_list] = newsletter_user.error_list
        redirect_to :back and return
      end
    end
    @title ||= "Sign up for our newsletter"
  end

  def page
    render :layout => true,:text => ""
  end

  def page_preview
    return deny unless @page = Page.find(:first,:conditions => ["pages.id = ?",params[:id]])
    @title = @page.name
    @notitle = @page.suppress_title?
    render :layout => true,:text => ""
  end

  def press
    @title ||= "#{site_name} Press Info"
    @press_releases = NewsItem.paginate(:conditions => ["news_items.kind = ?","Press Release"],:order => "news_items.date DESC,news_items.id DESC",:page => params[:page],:per_page => CMS.news_items_per_page)
  end

  def press_release
    return deny unless @press_release = NewsItem.find(:first,:conditions => ["news_items.slug = ? AND news_items.kind = ?",params[:id],"Press Release"],:include => [:news_item_contacts])
    @title = @press_release.name
  end

  def search
    @bodytitle ||= "Search"
    @title ||= "Search"
    if params[:q] && !params[:q].empty?
      @title << " Results: <b>#{params[:q]}</b>"
      @articles = Article.match(:body,params[:q],:boolean => true)
      @pages = Page.match(:body,params[:q],:boolean => true)
      @results = [@articles,@pages].flatten.sort{|a,b| a.relevance <=> b.relevance}
    end
  end

  def sitemap
    @title ||= "Site map"
    @pages = [Page.find(:all,:conditions => ["pages.active = ? AND pages.parent_id IS NULL",true],:include => [:children],:order => "pages.position ASC"),MainController.action_method_names.without("clickthrough","context_data","login","logout","index","newsletter","page","sitemap","wsdl").collect{|action|Page.new(:name => action.titleize,:slug => action)}].flatten#.sort{|page| page.name}
  end

  def unsubscribe
    @title ||= "Unsubscribe"
    if request.post? && params[:email] && user = User.find(:first,:conditions => ["users.active = ? AND users.email = ?",true,params[:email]])
      @page = nil
      subscriber_hash = {}
      for field in CMS.subscriber_fields
        subscriber_hash[field] = false
      end
      user.update_attributes(subscriber_hash)
      flash[:notice] = "Your e-mail address (#{user.email}) has been removed!"
      render :text => "",:layout => true
    end
  end

  protected
  def find_page
    return if params[:format] && params[:format] != 'html'
    if params[:action] == "page"
      slug = params[:path].empty? ? "homepage" : params[:path].pop
      if params[:path].empty?
        @page = Page.find(:first,:conditions => ["pages.active = ? AND pages.slug = ?",true,slug],:include => [{:snippet_attachments => [:snippet]}])
      else
        @page = Page.find(:first, :conditions => ['pages.slug = ? AND parents_pages.slug = ?', slug, params[:path].pop], :include => [:parent])
      end
    elsif CMS.page_urls[:main][params[:action].to_sym]
      @page = Page.find(:first,:conditions => ["pages.active = ? AND pages.controller = ? AND pages.action = ? AND pages.attached = ?",true,params[:controller],params[:action],true],:include => [{:snippet_attachments => [:snippet]}])
    end
    if @page
      @title = @page.name
      @notitle = @page.suppress_title?
      @meta_title = @page.meta_title && !@page.meta_title.blank? ? @page.meta_title : @page.name
      @meta_keywords = @page.meta_keywords
      @meta_description = @page.meta_description
      build_snippets(@page.snippet_attachments)
    elsif params[:action] == "page"
      return deny
    end
  end
end