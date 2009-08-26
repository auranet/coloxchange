String.class_eval { remove_method(:chars) } rescue NameError #fix for Rails 2.0 + Ruby 1.8.7
RAILS_GEM_VERSION = "2.0.2"
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/base/boot')

Rails::Initializer.run do |config|
  config.action_controller.session = {:session_key => "_fadc_session",:secret => "fad6b009ac5a89d8c2026b3db13f8ddbedd4d0ebe56e6bd030394688294aea6b6e7209ae3932c59f959a482fba38eab2ec6c1477fadb6c3db935a81bf908730d"}
  config.action_controller.session_store = :active_record_store
  # config.active_record.observers = :cacher,:garbage_collector
  # config.frameworks -= [:action_web_service]
  # config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map{|dir| File.directory?(lib = "#{dir}/lib") ? lib : dir}
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  # config.log_level = :debug
end

require 'will_paginate'
require 'json'