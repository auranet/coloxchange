class Newsletter < ActiveRecord::Base
  admin :browse_columns => [:name,:sent],:fields => [:name,:date,{:description => {:class => "half",:label => "Welcome text"}}],:reflections => [:newsletter_articles]
  attr_accessor :old_sent
  has_many :newsletter_articles,:include => [{:article => :user},:photo]

  def deliver(preview = nil)
    # spawn do
      Mail.deliver_newsletter(self,preview ? [preview] : User.find(:all,:conditions => ["users.active = ? AND users.subscriber = ?",true,true]))
    # end
  end

  protected
  def after_find
    self.old_sent = self.attributes["sent"]
  end

  def after_update
    self.deliver if self.sent && !self.old_sent
  end
end