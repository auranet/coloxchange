class RecentActivity < Widget
  def title
    "Recent Activity"
  end

  def render
    conditions = nil
    if self.user.admin_omnipotent?
      if self.options[:model]
        conditions = ["admin_actions.model = ?",self.options[:model]]
        if self.options[:id]
          conditions[0] << " AND model_id = ?"
          conditions.push(self.options[:id])
        end
      end
      recent_activity = AdminAction.find(:all,:conditions => conditions,:include => [:user],:limit => 5,:order => "admin_actions.created_at DESC")
    else
      recent_activity = self.user.admin_actions.select{|admin_action| admin_action.model = self.options[:model]}
      recent_activity = recent_activity.select{|admin_action| admin_action.model_id.to_s = self.options[:id].to_s} if self.options[:id]
      recent_activity = recent_activity.sort{|a,b,| a.created_at <=> b.created_at}.reverse[0,5]
    end
    if recent_activity.empty?
      return "No recent activity"
    else
      text = ""
      for action in recent_activity
        text << "<div class=\"recent-activity\"><table><tr valign=\"top\"><td class=\"user-icon\">#{link_to "<img alt=\"#{action.user.name}\" src=\"#{action.user.photo_src == "/images/no-photo-icon.gif" ? "/global/admin/images/no-photo-icon.gif" : action.user.photo_src(:admin_thumb)}\" />",:action => "edit",:model => "user",:id => action.user_id}</td><td><h3>#{action.user_name}</h3>#{action.action_name.capitalize} #{action.model.constantize.admin_name.singularize.downcase} #{link_to_unless action.action_name == "deleted",(action.model_name || "(no name)").shorten(20),:action => "edit",:model => action.model.tableize.singularize,:id => action.model_id}<div class=\"recent-activity-date\">#{action.created_at.ago_s}</div></td></tr></table></div>"
      end
      return text
    end
  end
end
