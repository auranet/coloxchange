class NotificationList < Widget
  def title
    "Notifications"
  end

  def render
    notifications = (Notification.filter(:notification_views__user_id__notin => [@user.id]) | Notification.filter(:notification_views__user_id__isnull => true)).filter(:admin_role_id__in => @user.admin_roles).find(:all)
    if !notifications.empty?
      text = ""
      for notification in notifications
        text << "<div class=\"notification\">
  <div class=\"notification-links\">#{link_to "View",notification.url} &middot; #{link_to "Ignore",notification.url+"?ignore=true"}</div>
  <div class=\"notification-title\">#{link_to notification.name,notification.url}</div>
  <div class=\"notification-message\">#{notification.message}</div>
  <div class=\"notification-date\">#{notification.created_at.ago_s} ago</div>
</div>"
      end
    else
      raise "Breaking render block"
    end
  end
end