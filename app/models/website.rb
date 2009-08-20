class Website < ActiveRecord::Base
  acts_as_list
  belongs_to :user
  validates_presence_of :url, :kind

  def name
    "<a class=\"new\" href=\"#{self.url}\">#{self.url}</a>"
  end

  protected
  def before_save
    return false if self.url == "http://"
    self.url = "http://#{self.url}" unless self.url =~ /^http[s]*:\/\//
  end
end