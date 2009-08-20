connect "global/admin/css/records.css",:controller => "admin",:action => "records_css"
connect "#{Base.urls["admin"]}",:controller => "admin",:action => "index"
connect "#{Base.urls["admin"]}/help/:id",:controller => "admin",:action => "help_section",:requirements => {:id => /[\w-]+/}
connect "#{Base.urls["admin"]}/settings",:controller => "admin",:action => "settings"
connect "#{Base.urls["admin"]}/:action/:id/:value",:controller => "admin", :value => nil, :requirements => {:action => /(admin_role_permissions|change_password|editor|settings|setup|widget)/}
connect "#{Base.urls["admin"]}/:model",:controller => "admin",:action => "browse",:requirements => {:model => /[a-z_]+/}
connect "#{Base.urls["admin"]}/:model/:order/:sort",:controller => "admin",:action => "browse",:requirements => {:model => /[a-z_]+/,:order => /\d+/,:sort => /(down|up)/}
connect "#{Base.urls["admin"]}/:model/:id",:controller => "admin",:action => "edit",:requirements => {:model => /[a-z_]+/,:id => /\d+/}
connect "#{Base.urls["admin"]}/:model/:id/delete",:controller => "admin",:action => "delete",:requirements => {:model => /[a-z_]+/,:id => /\d+/}
connect "#{Base.urls["admin"]}/:model/:id/list/:reflection",:controller => "admin",:action => "list",:requirements => {:model => /[a-z_]+/,:id => /\d+/,:reflection => /[a-z0-9_]+/}
connect "#{Base.urls["admin"]}/:model/:action",:controller => "admin",:requirements => {:action => /(deleteall$|export$|help$|import$|reports$|reorder$|search$)/,:model => /[a-z_]+/}
connect "#{Base.urls["admin"]}/:model/add",:controller => "admin",:action => "edit",:requirements => {:model => /[a-z_]+/}
connect "#{Base.urls["admin"]}/:model/add/bulk",:controller => "admin",:action => "bulk_add",:requirements => {:model => /[a-z_]+/}
connect "#{Base.urls["admin"]}/:model/filter",:controller => "admin",:action => "filter",:requirements => {:model => /[a-z_]+/}
connect "#{Base.urls["admin"]}/:model/page/:page",:controller => "admin",:action => "browse",:requirements => {:model => /[a-z_]+/,:page => /\d+/}