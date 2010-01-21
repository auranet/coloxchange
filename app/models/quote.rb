class Quote < ActiveRecord::Base
  admin :browse_columns => [:name, 'contact.name'], :order => ["created_at"]
  belongs_to :contact
  has_and_belongs_to_many :notes, :order => 'notes.created_at'

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

  protected
  def after_create
    Mail.deliver_quote(self)
  end
end