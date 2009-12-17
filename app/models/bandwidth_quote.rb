class BandwidthQuote < Quote
  attr_accessor :bandwidth_requirements_internet, :bandwidth_requirements_mpls_or_private_line
  has_many :addresses, :through => :quote_addresses
  has_many :quote_addresses, :dependent => :destroy, :order => 'quote_addresses.position', :foreign_key => :quote_id
  state :product, {'Internet' => 'internet', 'Private Line' => 'line_service', 'MPLS' => 'mpls', 'Voice' => 'mvoice', 'Other' => 'other'}
  validates_presence_of :product

  class << self
    def internet_options
      ['T1 1.5 mbps', 'DS3 20 mbps commit', 'DS3 30 mbps commit', 'DS3 full port', 'OC3 50 mbps commit', 'OC3 100 mbps commit', 'OC3 full port', 'OC12 100 mbps commit', 'OC12 200 mbps commit', 'OC12 300 mbps commit', 'OC12 full port', 'Fast E 20 mbps commit', 'Fast E 50 mbps commit', 'Fast E full port', 'Gig E 100 mbps commit', 'Gig E 200 mbps commit', 'Gig E 300 mbps commit', 'Gig E full port', 'Other']
    end

    def mpls_or_private_line_options
      ['T1 1.5 mbps', 'DS3 45 mbps', 'OC3 155 mbps', 'OC3c 155 mbps', 'OC12 622 mbps', 'OC12c 622 mbps', '100 Fast Ethernet', '100 mbps Ethernet', '600 mbps Ethernet', 'Gigabit Ethernet (1,000 mbps)', 'Other']
    end
  end

  def addresses_attributes=(addresses_attributes)
    self.quote_addresses.clear
    for address in addresses_attributes
      quote_address = QuoteAddress.new(:address => Address.new(address), :quote => self)
      self.quote_addresses.push(quote_address) if quote_address.valid? && quote_address.address.valid?
    end
  end

  def product
    BandwidthQuote::Product.hash.keys.include?(self.attributes['product']) ? self.attributes['product'] : 'other'
  end

  protected
  def before_save
    if self.bandwidth_requirements_internet && self.product_internet?
      self.bandwidth_requirements = self.bandwidth_requirements_internet
    elsif self.bandwidth_requirements_mpls_or_private_line && (self.product_mpls? || self.product_private_line?)
      self.bandwidth_requirements = self.bandwidth_requirements_mpls_or_private_line
    end
  end

  def validate
    self.errors.add(:addresses, self.product_internet_service? ? 'You must supply an address to connect' : 'You must supply one or more connection addresses') if self.quote_addresses.empty?
  end
end