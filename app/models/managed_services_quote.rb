class ManagedServicesQuote < Quote
  state :product, {'Managed Hosting' => 'a_managed_hosting', 'Cloud Computing' => 'b_cloud_computing', 'Hosted PBX' => 'c_hosted_pbx'}

  protected
  def validate
    self.errors.add(:note, 'You must describe your requirements') if self.note.blank?
  end
end