class MailingList < NameBasedModel
  admin :fields => [:name],:reflections => [:mailing_list_users]
  has_many :mailing_list_users,:order => "subscribed DESC",:dependent => :destroy
  has_many :users,:through => :mailing_list_users
  validates_presence_of :name
  write_inheritable_attribute(:defaults,[{:class_name => "User",:conditions => {:active => true,:subscriber => true},:name => "Subscribers"}])

  def id_or_name
    self.id || self.name
  end

  def self.defaults
    read_inheritable_attribute(:defaults).collect{|mailing_list| MailingList.new(:name => mailing_list[:name])}.sort{|a,b| a.name <=> b.name}
  end

  def self.subscribers
    self.new(:name => "All Subscribers",:mailing_list_users => User.filter(:subscriber => true).collect{|user| MailingListUser.new(:user => user)})
  end
end