class Address < ActiveRecord::Base
  acts_as_mappable
  attr_accessor :geocode_for_quote
  validates_presence_of :city, :state
  validates_presence_of :postal_code, :street, :if => :require_details?

  def address
    "#{"#{self.street.gsub("\n", "<br />")}<br />" if self.street}#{self.city}, #{self.state} #{self.postal_code}<br />#{self.country}"
  end

  def address_one_line
    self.address.gsub('<br />', ', ')
  end

  def lat_and_lng
    "#{self.lat}x#{self.lng}"
  end

  def name
    "#{self.address}#{"<br /><a class=\"external map-small icon quiet\" href=\"/admin/addresses/#{self.id}\">Map it!</a>" if self.lat && self.lng}"
  end

  protected
  def before_save
    self.errors.add(:street, 'cannot be blank') and return false if self.street == 'Street' && self.city == 'City' && self.state == '--' && self.postal_code =~ /^(Zip|Postal Code)$/
    self.street = nil if self.street == 'Street'
    self.city = nil if self.city == 'City'
    self.postal_code = nil if self.postal_code =~ /^(Zip|Postal Code)$/
    if self.geocode_for_quote && (!self.street || self.street.blank?) && (!self.postal_code || self.postal_code.blank?)
      geo = GeoKit::Geocoders::GoogleGeocoder.geocode(GeoKit::GeoLoc.new({:city => self.city, :state => self.state}))
    else
      geo = GeoKit::Geocoders::MultiGeocoder.geocode(self.address_one_line)
    end
    self.lat, self.lng = geo.lat, geo.lng if geo.success
    true
  end

  def require_details?
    !self.geocode_for_quote && (self.lat.nil? && self.lng.nil?)
  end
end