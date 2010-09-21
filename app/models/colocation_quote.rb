class ColocationQuote < Quote
  has_many :quote_data_centers, :dependent => :destroy, :foreign_key => :quote_id

  class << self
    def bandwidth_options
      # ["1 mbps", "2 - 5 mbps", "6 - 9 mbps", "10+ mbps", "50+ mbps", "100+ mbps", "250+ mbps", "500+ mbps"]
      BandwidthQuote.internet_options
    end

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

  def data_centers_description
    quote_data_centers.collect{|dc| dc.name}.join('; ')
  end

  protected
  def validate
    self.errors.add(:data_centers, 'You must select at least one data center') if self.quote_data_centers.empty?
  end
end
