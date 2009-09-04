class EquipmentQuote < Quote
  protected
  def validate
    self.errors.add(:new_equipment, 'You must provide equipment details here on in the notes field below') if self.product.blank? && self.note.blank?
  end
end