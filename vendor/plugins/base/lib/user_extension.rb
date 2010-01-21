module UserExtension
  mattr_accessor :admin_action_array,:admin_browse_column_array,:admin_condition_array,:admin_deletable_boolean,:admin_field_array,:admin_filter_array,:admin_include_array,:admin_order_string,:admin_reflection_array,:admin_search_field_array,:modifiers

  self.admin_action_array = []
  self.admin_browse_column_array = [:name,:email]
  self.admin_condition_array = ["(users.type IS NULL OR users.type = ?)","User"]
  self.admin_deletable_boolean = false
  self.admin_field_array = ["first_name","last_name","email","active","admin","created_at","updated_at","last_login"]
  self.admin_filter_array = [{:name => [:first_name,:last_name]},:email,:username,:active,:admin,:created_at]
  self.admin_include_array = [:photo]
  self.admin_order_string = "users.first_name ASC,users.last_name ASC"
  self.admin_reflection_array = [:admin_roles,:file_stores,:photos]
  self.admin_search_field_array = [:first_name,:last_name,:username,:email]
  self.modifiers = []

  def self.included(base)
    base.send :include, InstanceMethods
    base.extend ClassMethods
    if Rails.plugins[:admin]
      base.send :admin,{:actions => self.admin_action_array,:browse_columns => self.admin_browse_column_array,:conditions => self.admin_condition_array,:deletable => self.admin_deletable_boolean,:fields => self.admin_field_array,:filters => self.admin_filter_array,:include => self.admin_include_array,:order => self.admin_order_string,:reflections => self.admin_reflection_array,:search_fields => self.admin_search_field_array}
    end
    for cmds in self.modifiers
      eval("base.send #{cmds.collect{|cmd| cmd.inspect}.join(",")}")
    end
  end

  module ClassMethods
  end

  module InstanceMethods
  end
end