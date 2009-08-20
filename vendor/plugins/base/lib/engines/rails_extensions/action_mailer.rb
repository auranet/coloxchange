module Engines::RailsExtensions::ActionMailer
  def self.included(base)
    base.class_eval do
      alias_method_chain :template_path, :engine_additions
      alias_method_chain :initialize_template_class, :engine_additions
    end
  end

  private
  def template_paths
    paths = Engines.plugins.by_precedence.map { |p| "#{p.directory}/app/views/#{mailer_name}" }
    paths.unshift(template_path_without_engine_additions) unless Engines.disable_application_view_loading
    paths
  end

  def template_path_with_engine_additions
    "{#{template_paths.join(",")}}"
  end

  def initialize_template_class_with_engine_additions(assigns)
    renderer = initialize_template_class_without_engine_additions(assigns)
    renderer.view_paths = ActionController::Base.view_paths.dup
    renderer
  end
end

if Object.const_defined?(:ActionMailer) 
  module ::ActionMailer
    class Base
      include Engines::RailsExtensions::ActionMailer
    end
  end
end