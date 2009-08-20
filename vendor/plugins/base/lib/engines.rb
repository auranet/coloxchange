require 'active_support'
require File.join(File.dirname(__FILE__),'engines/plugin')
require File.join(File.dirname(__FILE__),'engines/plugin/list')
require File.join(File.dirname(__FILE__),'engines/plugin/loader')
require File.join(File.dirname(__FILE__),'engines/plugin/locator')
require File.join(File.dirname(__FILE__),'engines/assets')
require File.join(File.dirname(__FILE__),'engines/rails_extensions/rails')

module Engines
  mattr_accessor :plugins
  self.plugins = Engines::Plugin::List.new

  mattr_accessor :rails_extensions
  self.rails_extensions = %w(active_record action_mailer asset_helpers routing migrations dependencies)

  mattr_accessor :public_directory
  self.public_directory = File.join(RAILS_ROOT,'public','global')

  mattr_accessor :schema_info_table
  self.schema_info_table = "plugin_schema_info"

  mattr_accessor :disable_application_view_loading
  self.disable_application_view_loading = false

  mattr_accessor :disable_application_code_loading
  self.disable_application_code_loading = false

  mattr_accessor :disable_code_mixing
  self.disable_code_mixing = false

  mattr_accessor :code_mixing_file_types
  self.code_mixing_file_types = %w(controller helper)

  class << self
    def init
      load_extensions
      Engines::Assets.initialize_base_public_directory
    end

    def logger
      RAILS_DEFAULT_LOGGER
    end

    def load_extensions
      rails_extensions.each { |name| require "engines/rails_extensions/#{name}" }
      require "engines/testing" if RAILS_ENV == "test"
    end

    def select_existing_paths(paths)
      paths.select { |path| File.directory?(path) }
    end

    def mix_code_from(*types)
      self.code_mixing_file_types += types.map { |x| x.to_s.singularize }
    end

    def mirror_files_from(source,destination)
      return unless File.directory?(source)
      source_files = Dir[source + "/**/*"]
      source_dirs = source_files.select { |d| File.directory?(d) }
      source_files -= source_dirs
      source_dirs.each do |dir|
        target_dir = File.join(destination,dir.gsub(source,''))
        begin
          FileUtils.mkdir_p(target_dir)
        rescue Exception => e
          raise "Could not create directory #{target_dir}: \n" + e
        end
      end
      source_files.each do |file|
        begin
          target = File.join(destination,file.gsub(source,''))
          unless File.exist?(target) && FileUtils.identical?(file,target)
            FileUtils.cp(file,target)
          end
        rescue Exception => e
          raise "Could not copy #{file} to #{target}: \n" + e
        end
      end
    end
  end
end