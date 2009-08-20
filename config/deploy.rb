require 'railsmachine/recipes'
set :application, "application"
set :deploy_to, "/var/www/apps/#{application}"
set :domain, "#{application}.sasserinteractive.com"
set :user, "deploy"
set :repository, "svn+ssh://#{user}@#{domain}/var/repos/#{application}"
set :rails_env, "production"
set :app_symlinks, %w{uploads images/uploads}

role :web, domain
role :app, domain
role :db,  domain, :primary => true
role :scm, domain

# Apache options
set :apache_server_name, domain
# set :apache_server_aliases, %w{alias1 alias2}
# set :apache_default_vhost, true # force use of apache_default_vhost_config
# set :apache_default_vhost_conf, "/etc/httpd/conf/default.conf"
# set :apache_conf, "/etc/httpd/conf/apps/#{application}.conf"
# set :apache_ctl, "/etc/init.d/httpd"
set :apache_proxy_port, 8000
set :apache_proxy_servers, 1
# set :apache_proxy_address, "127.0.0.1"
# set :apache_ssl_enabled, false
# set :apache_ssl_ip, "127.0.0.1"
# set :apache_ssl_forward_all, false

# SSH options
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
# ssh_options[:port] = 25