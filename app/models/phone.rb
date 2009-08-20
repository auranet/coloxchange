class Phone < ActiveRecord::Base
  acts_as_list
  belongs_to :user
  validates_presence_of :number, :kind

  def name
    "#{self.number} (#{self.kind})"
  end

  protected
  def before_save
    self.number.gsub!(/[^0-9]/,"")
    self.number = self.number[1,self.number.size-1] if self.number[0,1] == "1"
    self.number = "(#{self.number[0,3]})&nbsp;#{self.number[3,3]}-#{self.number[6,4]}"
  end
end