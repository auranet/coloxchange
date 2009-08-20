require File.join(File.dirname(__FILE__), 'lib/engines')
{:default_plugin_locators => [Engines::Plugin::FileSystemLocator],:default_plugin_loader => Engines::Plugin::Loader,:default_plugins => [:base,:all]}.each do |name,default|
  Rails::Configuration.send(:define_method,name){default}
end