class User < ActiveRecord::Base
  attr_accessor :old_enable_email,:old_password,:send_creation_email
  include UserExtension
  belongs_to :photo
  has_many :file_stores,:conditions => ["type = ? OR type IS NULL",'FileStore']
  has_many :photos
  validates_confirmation_of :password,:message => "Your passwords did not match!"
  validates_format_of :email,:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,:message => Base::Messages.email_invalid,:if => :email_present?
  validates_format_of :username,:with => /^([a-z0-9_]+)$/i,:message => Base::Messages.username_illegal,:if => :use_username?
  validates_format_of :username,:with => /^.*?([a-z]+).*?$$/i,:message => Base::Messages.username_numeric,:if => :valid_username?
  validates_presence_of :email,:if => :require_email?
  validates_presence_of :password,:if => :authenticatable?
  validates_presence_of :username,:if => :use_username?
  validates_overall_uniqueness_of :email,:message => Base::Messages.email_taken,:if => :require_email?
  validates_uniqueness_of :username,:message => Base::Messages.username_taken,:if => :use_username?

  def self.authenticate(user)
    if user[:username]
      User.find(:first,:conditions => ["users.active = ? AND users.username = ? AND users.password = ?",true,user[:username],user[:password].encrypt])
    elsif user[:email]
      User.find(:first,:conditions => ["users.active = ? AND users.email = ? AND users.password = ?",true,user[:email],(user[:password] || "").encrypt])
    else
      nil
    end
  end

  def authenticatable?
    self.authenticates
  end

  def default_photo
    self.photo ? self.photo : Photo.new(:caption => "#{self.name.possessive} photo",:url => "/images/no-photo.gif")
  end

  def name
    if self.first_name and !self.first_name.blank? and self.last_name and !self.last_name.blank?
      "#{self.first_name} #{self.last_name}"
    elsif self.first_name and !self.first_name.blank?
      self.first_name
    elsif self.last_name and !self.last_name.blank?
      self.last_name
    elsif self.use_username?
      self.username
    else
      self.email
    end
  end

  def name_stressed
    "#{self.first_name} <b>#{self.last_name}</b>"
  end

  def name_with_email
    "#{self.name} <#{self.email}>"
  end

  def photo_src(size = :icon)
    (self.photo.nil? ? Photo.new(:url => "/images/no-photo.gif") : self.photo).size(size)
  end

  def reset_password
    new_password = "#{DateTime.now}".encrypt[0,8]
    self.update_attributes(:password => new_password,:change_password => true)
    Mail.deliver_user_password(self,new_password)
  end

  def short_name
    "#{self.first_name}#{" #{self.last_name[0,1]}." if self.last_name && !self.last_name.blank?}"
  end

  def use_username?
    Base.usernames
  end

  def self.name_attributes
    [:first_name,:last_name]
  end

  protected
  def after_find
    self.old_enable_email = self.attributes["enable_email"]
    self.old_password = self.attributes["password"]
    for method in User.instance_methods.select{|method| method =~ /after_find_/}
      self.send(method)
    end
  end

  def after_save
    if Base.email_support && self.username && !self.username.blank?
      begin;EmailUser.find_by_sql(["DELETE FROM users WHERE users.username = ? AND users.domain = ?",self.username,domain_short]);rescue;end if self.old_enable_email || self.enable_email
      EmailUser.create(:username => self.username,:domain => domain_short,:password => self.password) if self.enable_email
    end
  end

  def before_save
    if Base.verify_users && !self.verified && self.new_record?
      self.uniq_id = "#{self.id}#{DateTime.now.to_s}".encrypt[0,10]
      Mail.deliver_user_verification(self)
    elsif (!Base.verify_users || self.verified) && self.send_creation_email && self.send_creation_email != "0"
      Mail.deliver_new_user_password(self)
    end
    if self.old_password.nil? || (self.password && self.old_password != self.password)
      unless self.password.nil? || self.password.empty?
        self.password = self.password.encrypt
        self.old_password = self.password
      end
    end
  end

  def before_validation
    if self.username
      self.username.downcase!
    end
    unless self.password
      self.password = "#{DateTime.now}".encrypt[0,8]
      self.change_password = true
    end
  end

  def email_present?
    self.email && !self.email.strip.blank?
  end

  def require_email?
    true # Of course!
  end

  def valid_username?
    return false unless use_username?
    !(self.username =~ /^([a-z0-9_]+)$/i).nil?
  end
end