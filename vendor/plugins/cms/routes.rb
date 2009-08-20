require "base/configuration"
Configuration.startup
for method in MainController.action_method_names.without("article","articles","index","newsletter","newsletter_signup","news","news_item","press_release","press","sitemap")
  connect "#{method}/:id",:controller => "main",:action => method
end
if Rails.plugins[:admin]
  connect "#{Base.urls["admin"]}/:model/:id/preview",:controller => "admin",:action => "preview",:requirements => {:model => /(newsletter|page)/,:id => /\d+/}
  connect "#{Base.urls["admin"]}/:model/:id/expire",:controller => "admin",:action => "expire",:requirements => {:model => /[a-z_]+/,:id => /\d+/}
  connect "#{Base.urls["admin"]}/:model/mailinglist/add",:controller => "admin",:action => "mailing_list",:requirements => {:model => /[a-z_]+/}
  connect "#{Base.urls["admin"]}/emails/compose",:controller => "admin",:action => "email_compose"
  # connect "#{Base.urls["admin"]}/mailing_list/:id/send",:controller => "admin",:action => "mailing_list_send",:model => "mailing_list",:requirements => {:id => /\d+/}
  # connect "#{Base.urls["admin"]}/newsletter/:id/send",:controller => "admin",:action => "newsletter_send",:model => "newsletter",:requirements => {:id => /\d+/}
end
connect "#{Base.urls["cms_advertisement"]}",:controller => "main",:action => "advertisement"
connect "#{Base.urls["cms_clickthrough"]}/:id",:controller => "main",:action => "clickthrough"
connect "#{Base.urls["cms_news"]}/:page",:controller => "main",:action => "news",:page => nil,:requirements => {:page => /\d+/}
connect "#{Base.urls["cms_news"]}/:id",:controller => "main",:action => "news_item",:requirements => {:id => /[\w-]+/}
connect "#{Base.urls["cms_newsletter"]}/signup",:controller => "main",:action => "newsletter_signup"
connect "#{Base.urls["cms_newsletter"]}",:controller => "main",:action => "newsletter"
connect "#{Base.urls["cms_press_releases"]}/:page",:controller => "main",:action => "press",:page => nil,:requirements => {:page => /\d+/}
connect "#{Base.urls["cms_press_releases"]}/:id",:controller => "main",:action => "press_release",:requirements => {:id => /[\w-]+/}
connect "#{Base.urls["cms_sitemap"]}",:controller => "main",:action => "sitemap"
connect "#{Base.urls["cms_articles"]}",:controller => "main",:action => "articles",:id => nil
connect "#{Base.urls["cms_articles"]}/category/:category_id",:controller => "main",:action => "articles"
connect "#{Base.urls["cms_articles"]}/user/:user_id",:controller => "main",:action => "articles"
connect "#{Base.urls["cms_articles"]}/:id",:controller => "main",:action => "article"
connect "#{Base.urls["cms_search"]}/:id",:controller => "main",:action => "search" if CMS.search
connect "",:controller => "main",:action => "index"
page "*path", :controller => "main", :action => "page"