require "#{RAILS_ROOT}/vendor/plugins/base/app/apis/notification_a_p_i"
class NotificationService < ActionWebService::Base
  web_service_api NotificationAPI

  def createAuthTokenForUsernameAndPassword(username,password)
    if user = User.authenticate({:password => password}.update(Base.usernames ? {:username => username} : {:email => username}))
      auth_token = AuthToken.new(:user => user)
      if auth_token.save
        return auth_token.token
      end
    end
    return ""
  end

  def getNotifications(token)
    if user = AuthToken.validate(token)
      return user.notifications
    end
    return []
  end

  def hideNotification(token,id)
    if user = AuthToken.validate(token)
      if notification = Notification.find(:first,:conditions => ["notifications.id = ? ",id])
        if notification.notification_views.create(:user_id => user)
          return true
        end
      end
    end
    return false
  end
end
