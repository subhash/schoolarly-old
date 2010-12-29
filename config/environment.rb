# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')


require 'desert'
Rails::Initializer.run do |config|
  config.gem 'redhillonrails_core'
  config.gem 'acts_as_tree'
  config.gem 'RedCloth', :lib => 'redcloth', :source => 'http://code.whytheluckystiff.net'
  config.gem 'google-geocode', :lib => 'google_geocode', :version => '~> 1.2.1'
  config.reload_plugins = true if RAILS_ENV == 'development'
  config.gem 'oauth', :version => '>= 0.3.5'
  config.gem 'rubyist-aasm', :lib => 'aasm', :version => '~> 2.1.1'
  config.gem 'linkingpaths-acts_as_abusable', :lib => 'acts_as_abusable', :version => '0.0.2'
  config.gem 'mbleigh-acts-as-taggable-on', :lib => 'acts-as-taggable-on', :version => '1.0.5'
  config.gem 'RedCloth', :lib => 'redcloth', :version => '>= 4.2.0'
  config.gem 'mreinsch-acts_as_rateable', :lib => 'acts_as_rateable', :version => '2.0.1'
  config.gem 'jackdempsey-acts_as_commentable', :lib => 'acts_as_commentable', :version => '2.0.1'
  config.gem 'thoughtbot-factory_girl', :lib => 'factory_girl'
  config.gem 'tog-tog', :lib => 'tog', :version => '>= 0.5'
  config.gem 'mislav-will_paginate', :lib => 'will_paginate', :version => '~> 2.3.6'
  config.gem 'desert', :lib => 'desert', :version => '>= 0.5.2'
  config.gem 'i18n', :version => '= 0.4.0'
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end