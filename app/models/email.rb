class Email < ActiveRecord::Base
  acts_as_list :scope => :user_id
  belongs_to :user
  validates_presence_of :address, :kind

  def name
    "<a href=\"mailto:#{self.address}\">#{self.address}</a> (#{self.kind})"
  end
end