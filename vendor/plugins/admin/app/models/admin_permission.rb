class AdminPermission < ActiveRecord::Base
  belongs_to :admin_role
  def name
    "#{self.admin_role.name} (#{self.model.humanize})"
  end
end