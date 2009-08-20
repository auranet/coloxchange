require "#{RAILS_ROOT}/vendor/plugins/base/app/apis/notification_service"
class WebServiceController < ApplicationController
  web_service_dispatching_mode :delegated
  web_service :notifications, NotificationService.new
end