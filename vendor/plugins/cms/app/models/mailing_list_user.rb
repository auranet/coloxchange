class MailingListUser < ActiveRecord::Base
  admin :browse_columns => [:name,{:subscribed => "Subscribed?"}],:deletable => false,:name => "Recipient"
  attr_accessor :old_subscribed
  belongs_to :mailing_list
  belongs_to :user
  validates_presence_of :mailing_list,:user
  validates_uniqueness_of :user_id,:scope => :mailing_list_id,:message => "foo"

  def name
    self.user.name
  end

  def name_with_email
    self.user.name_with_email
  end

  protected
  def after_find
    self.old_subscribed = self.attributes["subscribed"]
  end

  def before_save
    if !self.subscribed && self.old_subscribed
      self.unsubscribed_at = DateTime.now
    end
  end
end