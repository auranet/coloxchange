module Configuration
  mattr_accessor :first_load,:site_name,:site_name_legal,:site_name_clean,:site_tag_line,:google_analytics_key,:google_maps_key,:self_advertise,:newsletter
  self.first_load = false
  self.newsletter = false
  self.self_advertise = false

  mattr_accessor :meta_keywords,:meta_description,:meta_author,:meta_copyright,:meta_robots
  self.meta_copyright = "Copyright &copy; %Y Your Company's Legal Name"
  self.meta_robots = "FOLLOW,INDEX"

  mattr_accessor :export_server,:export_port,:export_user,:export_password,:export_path
  self.export_path = 80

  def self.configuration_hash
    configuration = {}
    for key in [:first_load,:site_name,:site_name_legal,:site_tag_line,:google_analytics_key,:google_maps_key,:meta_keywords,:meta_description,:meta_author,:meta_copyright,:meta_robots,:newsletter]
      configuration[key] = self.send(key)
    end
    if defined?(Admin) && Admin.exportable
      for key in [:export_server,:export_port,:export_user,:export_password,:export_path]
        configuration[key] = self.send(key)
      end
    end
    configuration[:first_load] = false
    configuration
  end

  def self.save
    File.open("#{RAILS_ROOT}/config/site.yml","w") do |yml|
      YAML.dump(self.configuration_hash,yml)
    end
    GeoKit::Geocoders::google = self.google_maps_key if Rails.plugins[:geokit]
    self.first_load = false
  end

  def self.startup
    if File.exists?("#{RAILS_ROOT}/config/site.yml")
      if self.update(YAML::load(File.open("#{RAILS_ROOT}/config/site.yml")))
        self.site_name_clean = self.site_name.clean
      end
      self.first_load = false
    else
      self.first_load = true
    end
  end

  def self.update(configuration)
    for key,value in configuration
      if self.respond_to?(key)
        self.send("#{key}=",value)
      end
      if self.valid?
        true
      else
        false
      end
    end
  end

  def self.valid?
    self.site_name && !self.site_name.blank?
  end
end