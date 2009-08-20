module Engines::RailsExtensions::Templates
  module ActionView
    def self.included(base)
      base.class_eval { alias_method_chain :full_template_path, :engine_additions }
    end

    private
    def full_template_path_with_engine_additions(template_path, extension)
      path_in_app_directory = full_template_path_from_application(template_path, extension)
      return path_in_app_directory if path_in_app_directory && File.exist?(path_in_app_directory)
      Rails.plugins.by_precedence do |plugin|
        plugin_specific_path = File.join(plugin.root, 'app', 'views',
        template_path.to_s + '.' + extension.to_s)
        return plugin_specific_path if File.exist?(plugin_specific_path)
      end
      return full_template_path_without_engine_additions(template_path, extension)
    end
    def full_template_path_from_application(template_path, extension)
      if Engines.disable_application_view_loading
        nil
      else
        full_template_path_without_engine_additions(template_path, extension)
      end
    end
  end

  module Layout
    def self.included(base)
      base.class_eval { alias_method_chain :layout_list, :engine_additions }
    end

    private
    def layout_list_with_engine_additions
      plugin_layouts = Rails.plugins.by_precedence.map do |p|
        File.join(p.root, "app", "views", "layouts")
      end
      layout_list_without_engine_additions + Dir["{#{plugin_layouts.join(",")}}/**/*"]
    end
  end

  module MailTemplates
    def self.included(base)
      base.class_eval do
        alias_method_chain :template_path, :engine_additions
        alias_method_chain :render, :engine_additions
      end
    end

    private
    def template_paths
      paths = Rails.plugins.by_precedence.map { |p| "#{p.root}/app/views/#{mailer_name}" }
      paths.unshift(template_path_without_engine_additions) unless Engines.disable_application_view_loading
      paths
    end

    def template_path_with_engine_additions
      "{#{template_paths.join(",")}}"
    end

    def render_with_engine_additions(opts)
      template_path_for_method = Dir["#{template_path}/#{opts[:file]}*"].first
      body = opts.delete(:body)
      i = initialize_template_class(body)
      i.base_path = File.dirname(template_path_for_method)
      i.render(opts)
    end
  end
end

::ActionView::Base.send(:include, Engines::RailsExtensions::Templates::ActionView)
::ActionController::Layout::ClassMethods.send(:include, Engines::RailsExtensions::Templates::Layout)
if Object.const_defined?(:ActionMailer)
  ::ActionMailer::Base.send(:include, Engines::RailsExtensions::Templates::MailTemplates)
end