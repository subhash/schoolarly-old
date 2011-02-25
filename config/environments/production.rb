# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

config.action_mailer.delivery_method = :smtp


ActionMailer::Base.smtp_settings = {
  :enable_starttls_auto => true,
  :address => "smtp.gmail.com",
  :port => "587",
  :domain => "schoolarly.com",
  :authentication => :plain,
  :user_name => "test@schoolarly.com",
  :password => "testuser"
}

config.action_mailer.perform_deliveries = true
# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true


# Enable threaded mode
# config.threadsafe!

Tog::Plugins.settings :tog_core, {"storage" => "S3"}, :force => true
Tog::Plugins.settings :tog_core, {"storage.s3.path" => "/system/:class/:attachment/:id/:style_:basename.:extension"}, :force => true
Tog::Plugins.settings :tog_core, {"storage.s3.bucket" => "Schoolarly"}, :force => true
Tog::Plugins.settings :tog_core, {"storage.s3.access_key_id" => "AKIAIMQFQ2BSZ5X5SWFQ"}, :force => true
Tog::Plugins.settings :tog_core, {"storage.s3.secret_access_key" => "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"}, :force => true
Tog::Plugins.settings :tog_core, {"storage.s3.url" => "/system/:class/:attachment/:id/:style_:basename.:extension"}, :force => true
