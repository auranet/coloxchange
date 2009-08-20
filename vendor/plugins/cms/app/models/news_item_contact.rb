class NewsItemContact < ActiveRecord::Base
  admin :browse_columns => [:name,:company,:email],:fields => [:news_item,:name,:company,:email,:phone],:name => "Press Contact"
  belongs_to :news_item
  validates_presence_of :name,:news_item

  protected
  def before_save
    if self.phone && !self.phone.strip.blank?
      self.phone.gsub!(/[^0-9]/,"")
      self.phone = self.phone[1,self.phone.size-1] if self.phone[0,1] == "1"
      self.phone = "+1(#{self.phone[0,3]})&nbsp;#{self.phone[3,3]}-#{self.phone[6,4]}"
    end
  end
end