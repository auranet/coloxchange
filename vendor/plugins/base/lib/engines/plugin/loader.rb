module Engines
  class Plugin
    class Loader < Rails::Plugin::Loader
      protected
        def register_plugin_as_loaded(plugin)
          super plugin
          Engines.plugins << plugin
          register_to_routing(plugin)
        end

        def register_to_routing(plugin)
          initializer.configuration.controller_paths += plugin.select_existing_paths(:controller_paths)
          initializer.configuration.controller_paths.uniq!
        end
    end
  end
end