ActionController::Routing::Routes.draw do |map|
  # Base routes
  map.root :controller => 'main', :action => 'index'
  map.contact 'contact', :controller => 'main', :action => 'contact', :method => :get
  map.contact_send 'contact/send', :controller => 'main', :action => 'contact_send', :method => :post
  map.contact_sent 'contact/sent', :controller => 'main', :action => 'contact_sent'
  map.login 'login', :controller => 'main', :action => 'login'
  map.logout 'logout', :controller => 'main', :action => 'logout'
  map.search 'search', :controller => 'main', :action => 'search'

  # Data center routing
  map.data_center_search 'data-centers/search', :controller => 'main', :action => 'data_center_search'
  map.data_center_search 'data-centers/search.:format', :controller => 'main', :action => 'data_center_search'
  map.data_center 'data-centers/:id', :controller => 'main', :action => 'data_center', :id => nil, :requirements => {:id => /[a-z0-9-]+/}

  # Quotes
  map.quote 'quote', :controller => 'main', :action => 'quote', :conditions => {:method => :get}
  map.quote_submit 'quote', :controller => 'main', :action => 'quote_send', :conditions => {:method => :post}
  map.quote_sent 'quote/sent', :controller => 'main', :action => 'quote_sent'
  map.market_quote 'quote/:state/:city', :controller => 'main', :action => 'quote_colocation', :requirements => {:city => /[A-Za-z0-9\+\.-]+/, :state => /[A-Z]{2,4}/}
  map.bandwidth_quote 'quote/bandwidth', :controller => 'main', :action => 'quote_bandwidth'
  map.colocation_quote 'quote/colocation', :controller => 'main', :action => 'quote_colocation'
  map.equipment_quote 'quote/equipment', :controller => 'main', :action => 'quote_equipment'
  map.managed_services_quote 'quote/managed-services', :controller => 'main', :action => 'quote_managed_services'

  # Plugins
  map.from_plugin :base
end