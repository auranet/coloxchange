module Engines::RailsExtensions::Dependencies
  def self.included(base)
    base.class_eval { alias_method_chain :require_or_load,:engine_additions }
  end

  def require_or_load_with_engine_additions(file_name,const_path=nil)
    return require_or_load_without_engine_additions(file_name,const_path) if Engines.disable_code_mixing
    file_loaded = false
    Engines.code_mixing_file_types.each do |file_type|
      if file_name =~ /^(.*app\/#{file_type}s\/)?(.*_#{file_type})(\.rb)?$/
        base_name = $2
        Engines.plugins.each do |plugin|
          plugin_file_name = File.expand_path(File.join(plugin.directory,'app',"#{file_type}s",base_name))
          # Engines.logger.debug("checking plugin '#{plugin.name}' for '#{base_name}'")
          if File.file?("#{plugin_file_name}.rb")
            # Engines.logger.debug("==> loading from plugin '#{plugin.name}'")
            file_loaded = true if require_or_load_without_engine_additions(plugin_file_name,const_path)
          end
        end
        if Engines.disable_application_code_loading
          # Engines.logger.debug("loading from application disabled.")
        else
          app_file_name = File.join(RAILS_ROOT,'app',"#{file_type}s","#{base_name}")
          if File.file?("#{app_file_name}.rb")
            # Engines.logger.debug("loading from application: #{base_name}")
            file_loaded = true if require_or_load_without_engine_additions(app_file_name,const_path)
          else
            # Engines.logger.debug("File not found in application: #{base_name}")
          end
        end        
      end 
    end
    file_loaded || require_or_load_without_engine_additions(file_name,const_path)
  end  
end

module ::Dependencies
  include Engines::RailsExtensions::Dependencies
end