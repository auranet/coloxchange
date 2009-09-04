# require "RMagick"
class Photo < FileStore
  admin :conditions => nil,:browse_columns => [{:name_with_thumb => "Name"}],:fields => [:user,:caption,{:path => {:label => "Photo"}}],:filters => [:caption],:name => "Image",:include => nil,:search_fields => [:caption]
  attr_accessor :sizes

  def embed(size = :medium,options = {})
    "<img#{{:alt => self.name ? self.name.clean : "",:class => "photo",:src => self.size(size)}.update(options).to_html} />"
  end

  def name_with_thumb
    "#{self.embed(:admin_thumb)} #{self.name}"
  end

  def size(size = :medium)
    dir = File.dirname(self.url)
    ext = File.extname(self.url)
    base = File.basename(self.url,ext)
    "#{dir}/#{base}-#{size}#{ext}"
  end

  private
  def handle_upload
    if self.path.respond_to?(:read)
      begin
        image = Magick::Image.from_blob(self.path.read).first
        image.x_resolution = 72
        image.y_resolution = 72
        newpath = File.mkdir_with_date(Base.image_path)
        if self.path.respond_to?(:original_filename)
          filename = self.path.original_filename
          self.caption = self.path.original_filename unless self.caption && !self.caption.strip.blank?
          ext = File.extname(filename)
        elsif self.caption && !self.caption.empty?
          filename = self.caption
          ext = ".jpg"
        end
        filename = filename.downcase.gsub(/( |_)/,"-").gsub(/[^a-z0-9-]/,"")
        base = File.basename(filename,ext)
        (self.sizes || Base.image_sizes).each_pair do |size,options|
          next if options.nil?
          @filename = File.safe_path("#{newpath}/#{base}-#{size}#{ext}")
          for dimension in [:height,:width]
            options.delete(dimension) if options[dimension].nil?
          end
          options = {:width => 100000,:height => 100000}.update(options)
          newimage = image.copy
          case options[:method]
          when :crop
            newimage = newimage.crop_resized(options[:width],options[:height]) if image.columns > options[:width] || image.rows > options[:height]
          when :scale
            newimage = newimage.change_geometry("#{options[:width]}x#{options[:height]}") {|width,height,resize| resize.resize(width,height)} if image.columns > options[:width] || image.rows > options[:height]
          else
            raise "Resize method not supplied or invalid"
          end
          newimage.write(@filename)
        end
        if !self.caption || self.caption.strip.blank?
          self.caption = filename
        end
        self.path = File.safe_path("#{newpath}/#{base}#{ext}")
        self.url = self.path.gsub(File.expand_path("#{RAILS_ROOT}/public"),"")
      rescue Exception => e
        raise "#{e}"
        self.errors.add_to_base("The image file you uploaded could not be read. Please try again.")
        return false
      end
    elsif self.new_record?
      self.errors.add(:uploaded_file,"is an invalid format. Please try again.")
      return false
    end
  end

  def remove_upload
    if self.path
      dir = File.dirname(self.path)
      ext = File.extname(self.path)
      base = File.basename(self.path,ext)
      Base.image_sizes.each_pair do |size,options|
        filename = File.expand_path("#{dir}/#{base}-#{size}#{ext}")
        File.unlink(filename) if File.exists?(filename)
      end
    end
  end
end