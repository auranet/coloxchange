class ManagedServicesQuote < Quote
  protected
  def validate
    self.errors.add(:note, 'You must describe your requirements')
  end
end