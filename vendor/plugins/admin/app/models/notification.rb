class Notification < ActiveRecord::Base
  before_save :after_find
  belongs_to :admin_role
  has_many :notification_views
  validates_presence_of :admin_role,:name

  def after_find
    self.url = "#{Base.domain}/#{Base.urls[:admin]}/notification/#{self.id}"
  end
end