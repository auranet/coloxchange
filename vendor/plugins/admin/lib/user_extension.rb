module UserExtension
  self.modifiers.push([:attr_accessor,:admin_roles_cached],[:attr_accessor,:admin_permissions_cached],[:has_many,:admin_actions],[:has_many,:admin_widgets],[:has_many,:auth_tokens],[:has_and_belongs_to_many,:admin_roles,{:include => [:admin_permissions]}])

  module InstanceMethods
    def admin_permission(model)
      self.admin_permissions.select{|permission| permission.model.tableize == model.tableize}[0]
    end

    def admin_permissions
      self.admin_permissions_cached ||= self.admin_roles.collect{|role| role.admin_permissions}.flatten
      # return self.admin_permissions_cached
    end

    def admin_omnipotent?
      self.admin_role_cache.any?{|role| role.omnipotent}
    end

    def admin_role_cache
      self.admin_roles_cached ||= self.admin_roles# unless self.admin_roles_cached
      # return self.admin_roles_cached
    end

    def has_admin_permission?(model,action,instance = nil)
      return true if self.admin_omnipotent?
      self.admin_permissions.any?{|permission| permission.model.tableize == model.tableize && permission.attributes[action] && (!instance || !permission.must_own || (instance.respond_to?(:user_id) && instance.user_id == self.user_id))}
    end

    def has_admin_role?(role_name)
      return true if self.admin_omnipotent?
      self.admin_role_cache.any?{|role| role.name == role_name}
    end

    def notifications
      self.admin_role_cache.empty? ? [] : Notification.filter(:admin_role_id__in => self.admin_roles,:viewed => false).find
    end
  end
end