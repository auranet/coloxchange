require "base"
Engines.init if defined? :Engines

Base.urls = {"admin" => "admin","blog" => "blog","blog_rss" => "rss.xml","calendars" => "ical","cms_advertisement" => "adsrv","cms_articles" => "article","cms_clickthrough" => "click","cms_news" => "news","cms_newsletter" => "newsletter","cms_press_releases" => "pr","cms_search" => "search","cms_sitemap" => "sitemap","documentation" => "support","faq" => "faq","login" => "login","logout" => "logout","lost_password" => "password","social" => "home","store" => "store","video" => "video"}
if File.exists?("#{RAILS_ROOT}/config/plugin_routes.yml") && ymlroutes = YAML::load(File.open("#{RAILS_ROOT}/config/plugin_routes.yml"))
  Base.urls.update(ymlroutes)
end

require "#{RAILS_ROOT}/app/controllers/application"
ApplicationController.send(:include,Base::Application)

ActiveRecord::Base.send(:include,ActiveRecord::Acts::List)
ActiveRecord::Base.send(:include,ActiveRecord::Acts::Tree)
ActionView::Base.field_error_proc = Proc.new {|html_tag, instance| "<span class=\"#{Base::Style.error_field_class}\">#{html_tag}</span>"}

require "will_paginate"
WillPaginate.enable

require "money"