# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

config.after_initialize do
  require 'thinking_sphinx'
  unless RAILS_ENV == 'test' || ThinkingSphinx.sphinx_running?
    config = ThinkingSphinx::Configuration.instance
    FileUtils.mkdir_p config.searchd_file_path
    Dir["#{config.searchd_file_path}/*.spl"].each { |file| File.delete(file) }
    if system("#{config.bin_path}#{config.searchd_binary_name} --pidfile --config \"#{config.config_file}\"")
      sleep(2)
      if ThinkingSphinx.sphinx_running?
        puts "Started successfully (pid #{ThinkingSphinx.sphinx_pid})."
      else
        puts "Failed to start searchd daemon. Check #{config.searchd_log_file}"
      end
    end
  end

  Page.class_eval do
    define_index do
      indexes :name, :body
    end
  end
end