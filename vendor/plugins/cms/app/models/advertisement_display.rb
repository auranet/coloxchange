class AdvertisementDisplay
  attr_accessor :categories,:location,:height,:width
  def initialize(options = {})
    self.categories = options[:categories]
    self.location = options[:location]
    self.height = options[:height]
    self.width = options[:width]
  end

  def to_s
    "<iframe class=\"advertisement\" frameborder=\"0\" height=\"#{self.height}\" scrolling=\"no\" src=\"/#{Base.urls["cms_advertisement"]}?#{"lat=#{self.location.lat}&amp;lng=#{self.location.lng}" if self.location}#{"&amp;categories[]=#{self.categories.collect{|category| c.is_a?(ActiveRecord::Base) ? c.id : c}.join("&amp;categories[]=")}" if self.categories && !self.categories.empty?}&amp;height=#{self.height}&amp;width=#{self.width}\" width=\"#{self.width}\"></iframe>"
  end
end