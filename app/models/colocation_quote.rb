class ColocationQuote < Quote
  has_many :quote_data_centers, :dependent => :destroy

  class << self
    def power_options
      ["Less than 15 amps", "15 amps", "20 amps", "30 amps", "40 amps total (2 x 20 amp circuits)", "60 amps total (2 x 30 amp circuits)", "Other"]
    end
  end

  def data_centers=(data_centers)
    self.quote_data_centers.clear
    for slug, data_center in data_centers
      next unless data_center['include'] == 'true'
      quote_data_center = QuoteDataCenter.new(:data_center_slug => data_center['slug'], :name => data_center['name'], :quote => self)
      self.quote_data_centers.push(quote_data_center) if quote_data_center.valid?
    end
  end

  protected
  def validate
    self.errors.add(:data_centers, 'You must select at least one data center') if self.quote_data_centers.empty?
  end
end