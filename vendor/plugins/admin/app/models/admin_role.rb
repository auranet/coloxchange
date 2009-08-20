class AdminRole < ActiveRecord::Base
  admin :browse_columns => [:name,:omnipotent?],:name => "User Role",:order => "admin_roles.omnipotent DESC,admin_roles.name ASC",:reflections => [:users]
  has_many :admin_permissions, :dependent => :destroy
  has_and_belongs_to_many :users

  def omnipotent?
    self.omnipotent ? "Yes" : "No"
  end
end