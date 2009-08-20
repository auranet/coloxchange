class FileStore < ActiveRecord::Base
  admin :bulk_fields => [{:caption => {:label => "Name"}},:path],:conditions => ["type IS NULL"],:fields => ["user","caption",{:path => {:label => "File"}}],:name => "File",:order => "LOWER(file_stores.caption)",:search_fields => [:caption]
  attr_accessor :old_path
  before_destroy :remove_upload
  before_validation :handle_upload
  belongs_to :user
  validates_presence_of :url

  def filename
    self.path ? self.path[self.path.rindex("/")+1,self.path.length] : self.url[self.url.rindex("/")+1,self.url.length]
  end

  def name
    self.caption && !self.caption.blank? ? self.caption : self.filename
  end

  def read
    File.open(self.path,"r").read
  end

  def size
    File.size(self.path)
  rescue
    0
  end

  protected
  def after_find
    self.old_path = self.attributes["path"]
  end

  def before_save
    self.caption = self.filename if self.caption.blank?
  end

  def handle_upload
    if self.path.respond_to?(:read)
      begin
        file = self.path.read
        self.path = File.safe_path("#{File.mkdir_with_date(Base.file_path)}/#{self.path.original_filename.downcase.gsub(/( |_)/,"-").gsub(/[^a-z0-9-]/,"")}")
        File.open(self.path,"wb").write(file)
        self.url = self.path.gsub(File.expand_path("#{RAILS_ROOT}/public"),"")
      rescue Exception => e
        raise e
        errors.add_to_base("The file you uploaded could not be read. Please try again.")
      end
    elsif self.path.blank? && !self.new_record?
      self.path = self.old_path
    end
  end

  def remove_upload
    File.unlink(self.path) if File.exists?(self.path)
    true
  end
end