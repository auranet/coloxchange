require "engines/rails_extensions/rails"
require 'engines/plugin_list'

module Engines::RailsExtensions::RailsInitializer
  def self.included(base)
    base.class_eval do
      alias_method_chain :load_plugin, :engine_additions
      alias_method_chain :after_initialize, :engine_additions
      alias_method_chain :plugin_enabled?, :engine_additions
    end
  end

  def load_all_plugins
    find_plugins(configuration.plugin_paths).sort.each { |path| load_plugin path }
  end

  def load_plugin_with_engine_additions(directory)
    name = plugin_name(directory)
    return false if loaded_plugins.include?(name)
    plugin = Plugin.new(plugin_name(directory), directory)
    Rails.plugins << plugin
    load_plugin_without_engine_additions(directory)
    plugin.load
    true
  end

  def after_initialize_with_engine_additions
    Engines.after_initialize
    after_initialize_without_engine_additions
  end

  protected
  def plugin_enabled_with_engine_additions?(path)
    Engines.load_all_plugins? || plugin_enabled_without_engine_additions?(path)
  end

  def plugin_name(path)
    File.basename(path)
  end
end

::Rails::Initializer.send(:include, Engines::RailsExtensions::RailsInitializer)