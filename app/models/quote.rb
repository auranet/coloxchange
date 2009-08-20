class Quote < ActiveRecord::Base
  admin :order => ["created_at"]
  has_and_belongs_to_many :notes, :order => 'notes.created_at'

  def note
    (self.notes.first || Note.new).body
  end

  def note=(body)
    note = Note.new(:body => body)
    self.notes.push(note) if note.valid?
  end
end