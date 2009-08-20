class Advertisement < ActiveRecord::Base
  admin :browse_columns => [:name,:expiration],:reflections => [:advertisement_regions]
  attr_accessor :force_url,:path,:size
  belongs_to :photo
  has_and_belongs_to_many :advertisement_regions
  has_many :clicks,:as => :item
  has_many :impressions,:as => :item
  validates_presence_of :kind,:name,:url

  def expiration
    self.ends_on.pretty_short
  end

  def to_s
    self.kind == "text" ? self.body : self.kind == "remote_photo" ? "<img alt=\"\" width=\"#{self.height}\" src=\"#{self.photo_url}\" width=\"#{self.width}\" />" : self.kind == "photo" && self.photo ? self.photo.embed(:large) : "<img alt=\"Your ad here\" height=\"#{self.height}\" src=\"/images/advertisements/your-ad-here-#{self.width}x#{self.height}.gif\" width=\"#{self.width}\" />"
  end

  protected
  def before_create
    self.uniq_id = "#{"#{DateTime.now}#{self.id}#{self.photo_id}#{self.kind}".encrypt[0,10]}#{"#{Date.today}#{self.kind}".encrypt[0,32]}" # Life, the universe, etc
  end

  def before_save
    self.regional = !self.advertisement_region_ids.empty?
    if self.path && self.path.respond_to?(:read) && self.kind == "photo"
      self.photo = Photo.create(:caption => "Banner ad: #{self.name}",:path => self.path)
    end
    if self.size && self.size = CMS.advertisement_sizes[self.size]
      self.height = self.size[:height]
      self.width = self.size[:width]
    end
  end
end