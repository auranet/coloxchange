module Engines::RailsExtensions::AssetHelpers
  def self.included(base)
    base.class_eval do
      [:stylesheet_link_tag, :javascript_include_tag, :image_path, :image_tag].each do |m|
        alias_method_chain m, :engine_additions
      end
    end
  end

  def stylesheet_link_tag_with_engine_additions(*sources)
    stylesheet_link_tag_without_engine_additions(*Engines::RailsExtensions::AssetHelpers.pluginify_sources("stylesheets", *sources))
  end

  def javascript_include_tag_with_engine_additions(*sources)
    javascript_include_tag_without_engine_additions(*Engines::RailsExtensions::AssetHelpers.pluginify_sources("javascripts", *sources))
  end

  def image_path_with_engine_additions(source, options={})
    options.stringify_keys!
    source = Engines::RailsExtensions::AssetHelpers.plugin_asset_path(options["plugin"], "images", source) if options["plugin"]
    image_path_without_engine_additions(source)
  end

  def image_tag_with_engine_additions(source, options={})
    options.stringify_keys!
    if options["plugin"]
      source = Engines::RailsExtensions::AssetHelpers.plugin_asset_path(options["plugin"], "images", source)
      options.delete("plugin")
    end
    image_tag_without_engine_additions(source, options)
  end

  def self.pluginify_sources(type, *sources)
    options = sources.last.is_a?(Hash) ? sources.pop.stringify_keys : { }
    sources.map! { |s| plugin_asset_path(options["plugin"], type, s) } if options["plugin"]
    options.delete("plugin")
    sources << options
  end  

  def self.plugin_asset_path(plugin_name, type, asset)
    raise "No plugin called '#{plugin_name}' - please use the full name of a loaded plugin." if Engines.plugins[plugin_name].nil?
    "/#{Engines.plugins[plugin_name].public_asset_directory}/#{type}/#{asset}"
  end
end

module ::ActionView::Helpers::AssetTagHelper
  include Engines::RailsExtensions::AssetHelpers
end