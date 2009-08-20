# require "#{RAILS_ROOT}/vendor/plugins/base/app/apis/notification_service"
class NotificationAPI < ActionWebService::API::Base
  api_method :createAuthTokenForUsernameAndPassword, :expects => [{:username => :string},{:password => :string}], :returns => [:string]
  api_method :getNotifications, :expects => [{:token => :string}], :returns => [[Notification]]
  api_method :hideNotification, :expects => [{:token => :string},{:id => :integer}], :returns => [:boolean]
end