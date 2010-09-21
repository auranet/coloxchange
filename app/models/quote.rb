class Quote < ActiveRecord::Base
  admin :browse_columns => [:name, 'contact.name', {'contact.customer_code' => 'Code'}, {'created_at.pretty_short' => 'Date'}], :order => ["created_at DESC"]
  belongs_to :contact
  has_and_belongs_to_many :notes, :order => 'notes.created_at'

  def address_description
    ''
  end

  def data_centers_description
    ''
  end

  def name
    "#{self.class.to_s.titleize} ##{id}"
  end

  def note
    (self.notes.first || Note.new).body
  end

  def note=(body)
    note = Note.new(:body => body)
    self.notes.push(note) if note.valid?
  end

  def self.admin_actions
    [
      ['Export', 'export'],
    ]
  end

  def self.export_columns
    [
      'id',
      'created_at',
      'contact.name',
      'contact.customer_code',
      'contact.contact_method_preference',
      'contact.email',
      'contact.phone',
      'contact.referrer',
      'contact.referring_site',
      'contact.search_term',
      'contact.note',
      'product',
      'type',
      'bandwidth_requirements',
      'address_description',
      'data_centers_description',
      'price_target',
      'new_equipment',
      'space',
      'bandwidth',
      'power',
      'target_date',
    ]
  end

  protected
  def after_create
    Mail.deliver_quote(self)
  end
end
