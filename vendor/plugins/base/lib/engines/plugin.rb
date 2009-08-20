module Engines
  class Plugin < Rails::Plugin    
    attr_accessor :code_paths
    attr_accessor :controller_paths
    attr_accessor :public_directory   

    protected
    def default_code_paths
      %w(app/controllers app/helpers app/models components lib)
    end

    def default_controller_paths
      %w(app/controllers components)
    end

    def default_public_directory
      Engines.select_existing_paths(%w(public).map { |p| File.join(directory,p) }).first
    end

    public
    def initialize(directory)
      super directory
      @code_paths = default_code_paths
      @controller_paths = default_controller_paths
      @public_directory = default_public_directory
    end

    def load_paths
      report_nonexistant_or_empty_plugin! unless valid?
      select_existing_paths :code_paths
    end

    def load(initializer)
      return if loaded?
      super initializer
      add_plugin_view_paths
      Assets.mirror_files_for(self)
      Dependencies.load_once_paths = Dependencies.load_once_paths.select{|path| (path =~ /#{name}\/app/).nil?} if ::RAILS_ENV == 'development'
    end    

    def select_existing_paths(name)
      Engines.select_existing_paths(self.send(name).map { |p| File.join(directory,p) })
    end    

    def add_plugin_view_paths
      view_path = File.join(directory,'app','views')
      if File.exist?(view_path)
        ActionController::Base.view_paths.insert(1,view_path)
      end
    end

    def public_asset_directory
      "#{File.basename(Engines.public_directory)}/#{name}"
    end

    def routes_path
      File.join(directory,"routes.rb")
    end

    def migration_directory
      File.join(self.directory,'db','migrate')
    end

    def latest_migration
      migrations = Dir[migration_directory+"/*.rb"]
      return nil if migrations.empty?
      migrations.map { |p| File.basename(p) }.sort.last.match(/0*(\d+)\_/)[1].to_i
    end

    def migrate(version = nil)
      Engines::Plugin::Migrator.migrate_plugin(self,version)
    end
  end
end