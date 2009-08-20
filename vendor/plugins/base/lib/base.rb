require "base/active_record_extension"
require "base/active_record/acts"
require "base/active_record/validations"
require "base/application"
require "base/configuration"
require "base/extensions"
require "base/messages"
require "base/object"
require "base/style"
require "#{RAILS_ROOT}/vendor/plugins/base/app/helpers/application_helper"
require "#{RAILS_ROOT}/vendor/plugins/base/lib/mail_extension"
require "#{RAILS_ROOT}/vendor/plugins/base/lib/user_extension"
require "#{RAILS_ROOT}/app/models/mail_extension" if File.exists?("#{RAILS_ROOT}/app/models/mail_extension.rb")
require "#{RAILS_ROOT}/app/models/user_extension" if File.exists?("#{RAILS_ROOT}/app/models/user_extension.rb")

module Base
  ########################
  #  Site Configuration  #
  ########################
  mattr_accessor :admin_email,:apps,:domain,:domain_short,:emails,:email_support,:google_maps_api_key,:urls
  self.admin_email = "support@sasserinteractive.com"
  self.domain = "http://www.example.com"
  self.domain_short = "example.com"
  self.emails = {:robot => "no-reply",:support => "support"}
  self.email_support = false

  #####################
  #  File management  #
  #####################
  mattr_accessor :file_path,:file_url,:image_path,:image_resize,:image_sizes,:image_url

  # Ensure we have folders ready for uploads
  self.file_url = "/uploads"
  self.file_path = File.expand_path("#{RAILS_ROOT}/public#{self.file_url}")

  # Ditto for images
  self.image_url = "/images/uploads/"
  self.image_path = File.expand_path("#{RAILS_ROOT}/public#{self.image_url}")

  # Set some default image sizes for resizing
  self.image_resize = true
  self.image_sizes = {:large => {:method => :scale,:width => 800,:height => 600},:medium => {:method => :scale,:width => 200},:icon => {:method => :crop,:width => 75,:height => 75}}

  ###########################################
  #  Authentication and session management  #
  ###########################################
  mattr_accessor :after_login_url,:after_logout_url,:find_user_options,:login_url,:usernames,:store_in_session,:verify_users

  # Where are we redirecting the user on successful login?
  self.after_login_url = {:controller => "home",:action => "index"}

  # Where are we redirecting after a logout?
  self.after_logout_url = {:controller => "main",:action => "login"}

  # What extra options are we including when we find a logged in user by their session id?
  self.find_user_options = {}

  # Where is the default login mechanism located?
  self.login_url = {:controller => "main",:action => "login"}

  # Are we storing marshaled authentication data in the session or just IDs? False for large sites
  self.store_in_session = false

  # Are we using usernames for validation/autentication? Usually only applies to social sites
  self.usernames = false

  # Require user verification
  self.verify_users = false

  ##################
  #  Web Services  #
  ##################
  mattr_accessor :enable_web_services,:web_service_url
  self.enable_web_services = false
  self.web_service_url = "api"

  #####################
  #  General Commerce #
  #####################
  mattr_accessor :currency,:currency_symbol
  self.currency = "USD"
  self.currency_symbol = "$"

  ###########################
  #  Ruby class extensions  #
  ###########################
  Array.send :include,Extensions::ArrayExtension
  Date.send :include,Extensions::DateExtension
  DateTime.send :include,Extensions::TimeExtension
  File.extend Extensions::FileExtension
  Hash.send :include,Extensions::HashExtension
  Numeric.send :include,Extensions::NumericExtension
  String.send :include,Extensions::StringExtension
  Time.send :include,Extensions::TimeExtension
  Time.extend Extensions::TimeClassExtension

  def self.startup
    Configuration.startup
    Dir.mkdir(self.file_path,0777) unless File.exists?(self.file_path)
    Dir.mkdir(self.image_path,0777) unless File.exists?(self.image_path)
    modules = {:admin => "Admin",:auth => "Auth",:blog => "Blog",:calendar => "CalendarModule",:captcha => "Captcha",:cms => "CMS",:crm => "CRM",:donations => "Donations",:linguo => "Linguo",:media => "Media",:payments => "Payments",:queryset => "QuerySet",:social => "Social",:store => "Store",:subscriptions => "Subscriptions",:quickbooks => "QuickBooks"}
    for plugin in modules.keys.sort{|a,b| a.to_s <=> b.to_s}
      if Rails.plugins[plugin]
        mod = modules[plugin].constantize
        mod.startup if mod.respond_to?(:startup)
        require "#{RAILS_ROOT}/vendor/plugins/#{plugin}/app/helpers/application_helper" if File.file?("#{RAILS_ROOT}/vendor/plugins/#{plugin}/app/helpers/application_helper.rb")
        for extension in ["mail","user"]
          require "#{RAILS_ROOT}/vendor/plugins/#{plugin}/lib/#{extension}_extension" if File.exists?("#{RAILS_ROOT}/vendor/plugins/#{plugin}/lib/#{extension}_extension.rb")
        end
      end
    end
    self.image_sizes[:admin_thumb] = {:method => :crop,:height => 48,:width => 48} if Rails.plugins[:admin]
    for type,email in self.emails
      self.emails[type] = "#{email}@#{self.domain_short}" unless email.include?("@")
    end
    Object.send :include,Base::ObjectExtensions
  end
end

ActiveRecord::Base.send :include,Base::ActiveRecordExtension