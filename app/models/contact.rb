class Contact < User
  admin :conditions => ["users.type = ?", "Contact"], :filters => [:name, :email], :include => [:emails], :order => ["first_name, last_name"], :name => "Contact"
  attr_accessor :contact_request, :hidden
  state :status, {'New' => 0, 'Active' => 1, 'Closed' => 2, 'Inactive' => 3}, :aggregates => {'Open' => ['New', 'Active', 'Closed']}
  belongs_to_and_edits_inline :company
  has_many :notes
  validates_presence_of :company_name, :message => "Company can't be blank"
  validates_presence_of :email, :phone

  def email
    (self.emails.first || Email.new(:address => self.attributes["email"])).address
  end

  def email=(address)
    email = Email.new(:address => address,:kind => "Work",:user => self)
    self.emails.push(email) if email.valid?
    super
  end

  def name_with_email
    "#{self.name} <#{self.email || "no e-mail"}>"
  end

  def note
    (self.notes.select{|note| note.user_id.blank?}.first || Note.new).body
  end

  def note=(body)
    note = Note.new(:body => body)
    self.notes.push(note) if note.valid?
  end

  def phone
    (self.phones.first || Phone.new).number
  end

  def phone=(number)
    phone = Phone.new(:kind => "Work",:number => number,:user => self)
    self.phones.push(phone) if phone.valid?
  end

  protected
  def after_create
    Mail.deliver_contact_confirmation(self)
  end

  def after_save
    if self.contact_request
      Mail.deliver_contact_request(self)
    end
  end

  def before_save
    self.authenticates = false
    self.attributes['email'] ||= self.email
    true
  end

  def validate
    if self.contact_request
      self.errors.add(:email, "can't be blank") if self.email.blank?
      self.errors.add(:phone, "can't be blank") if self.phone.blank?
      self.errors.add(:note, "can't be blank") if self.note.blank?
    end
    if self.first_name.blank? && self.last_name.blank?
      self.errors.add(:first_name, "Name can't be blank")
      self.errors.add(:last_name, "Name can't be blank")
    end
    super
  end
end