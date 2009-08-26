class AdminSweeper < ActionController::Caching::Sweeper
  observe Article,Menu,MenuItem,Newsletter,Page,Snippet

  def after_save(record)
    if (record.is_a?(MenuItem) && record.menu) || record.is_a?(Menu)
      expire_fragment(:controller => "main", :action => "#{(record.is_a?(MenuItem) ? record.menu : record).slug}_menu")
      articles = Article.find(:all)
      pages = Page.find(:all)
    elsif record.is_a?(Page)
      pages = [record.self_and_active_siblings,record.ancestors,record.active_children].flatten
    elsif record.is_a?(Snippet)
      pages = record.snippet_attachments.select{|snippet_attachment| snippet_attachment.attach_to == "page"}.collect{|snippet_attachment| snippet_attachment.page}.compact.uniq
      expire_actions(record.snippet_attachments.select{|snippet_attachment| snippet_attachment.attach_to == "action"}.collect{|snippet_attachment| {:controller => snippet_attachment.attributes["controller"],:action => snippet_attachment.action,:id => snippet_attachment.id_}}.compact.uniq)
    elsif record.is_a?(Article)
      articles = [record]
    elsif record.is_a?(Newsletter)
      expire_page(:controller => "main",:action => "newsletter")
    end
    expire_articles(articles) unless articles.nil?
    expire_pages(pages) unless pages.nil?
  end

    def after_destroy(record)
    after_save(record)
  end

  private
  def expire_actions(actions)
    for action in actions
      begin
        expire_page(action)
      rescue ActionController::RoutingError
        logger.warn("\nRouting failed for #{action.inspect} on AdminSweeper#expire_actions\n")
      end
    end
  end

  def expire_articles(articles)
    for article in articles
      expire_page(:controller => "main",:action => "article",:id => article.slug)
    end
  end

  def expire_pages(pages)
    for page in pages
      url = page.url
      expire_page(url.is_a?(Hash) ? url : {:controller => "main",:action => "page",:path => url[1,url.length].split("/")})
    end
  end
end