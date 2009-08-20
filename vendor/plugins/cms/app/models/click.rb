class Click < ActiveRecord::Base
  attr_accessor :new_keywords
  belongs_to :item,:polymorphic => true
  belongs_to :user
  has_and_belongs_to_many :keywords
  validates_presence_of :item

  def date
    self.created_at.to_date
  end

  def name
    "From #{self.ip} at #{self.created_at.pretty}"
  end

  protected
  def before_save
    self.keywords = Keyword.find(self.new_keywords) if self.new_keywords
    self.item.clicks.find(:all,:conditions => ["clicks.ip = ? AND clicks.created_at > ?",self.ip,2.hours.ago]).empty?
  end
end