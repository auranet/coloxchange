class User < ActiveRecord::Base
  include UserExtension
  admin :search_fields => [:first_name, :last_name]
  attr_accessor :old_enable_email, :old_password, :send_creation_email
  belongs_to :photo
  has_many :advertisements, :foreign_key => :manager_id
  has_many_and_edits_inline :addresses,{:order => "addresses.position ASC"}
  has_many_and_edits_inline :emails,{:dependent => :destroy}
  has_many_and_edits_inline :phones,{:dependent => :destroy}
  has_many_and_edits_inline :websites,{:dependent => :destroy}
  state :contact_method, {'Phone' => 0, 'E-mail' => 1}
  validates_confirmation_of :password,:message => "The passwords did not match!"
  validates_format_of :email,:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,:if => :email_present?
  validates_presence_of :email,:if => :user?
  validates_presence_of :first_name, :if => :require_first_name?,:message => "Name cannot be blank"
  validates_presence_of :password,:if => :authenticatable?
  validates_overall_uniqueness_of :email,:unless => :contact?

  def self.authenticate(user)
    User.find(:first,:conditions => ["users.authenticates = ? AND users.active = ? AND users.email = ? AND users.password = ?",true,true,user[:email],user[:password].encrypt])
  end

  def authenticatable?
    self.authenticates
  end

  def contact?
    self.is_a?(Contact)
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
    else
      self.email
    end
  end

  def name=(value)
    value = value.split(" ")
    self.first_name = value.shift
    self.last_name = value.join(" ")
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

  def user?
    !self.is_a?(Contact)
  end

  protected
  def after_find
    self.old_enable_email = self.attributes["enable_email"]
    self.old_password = self.attributes["password"]
    for method in User.instance_methods.select{|method| method =~ /after_find_/}
      self.send(method)
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
    unless self.password
      self.password = "#{DateTime.now}".encrypt[0,8]
      self.change_password = true
    end
  end

  def email_present?
    self.user? && self.email && !self.email.strip.blank?
  end

  def require_first_name?
    !self.is_a?(Contact) && (!self.first_name || self.first_name.blank?) && (self.last_name || self.last_name.blank?)
  end
end