connect "#{Base.urls["login"]}",:controller => "main",:action => "login"
connect "#{Base.urls["logout"]}",:controller => "main",:action => "logout"
connect "#{Base.urls["lost_password"]}",:controller => "main",:action => "lost_password"
if Base.enable_web_services
  connect "#{Base.web_service_url}/:action/:id",:controller => "web_service"
end
for plugin in [:admin,:blog,:calendar,:documentation,:media,:property,:social,:store,:cms]
  from_plugin plugin if Rails.plugins[plugin]
end
connect ":action/:id",:controller => "main"