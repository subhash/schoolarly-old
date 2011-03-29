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
  config.gem 'aasm'
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
  
  config.gem 'aws-s3', :lib => 'aws/s3'
  config.gem 'right_aws'
  config.gem 'rest-client'
  config.gem 'tiny_mce'
  
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
  config.time_zone = 'Chennai'
  
  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'criterion', 'criteria'
end


Tog::Interface.sections(:site).clear

Tog::Interface.sections(:member).tabs(:home).url = '/member'
Tog::Interface.sections(:member).remove "My groups"
Tog::Interface.sections(:member).remove "My account"
Tog::Interface.sections(:member).remove "My sharings"
Tog::Interface.sections(:member).add :attachments, "/member/attachments"
Tog::Interface.sections(:member).add :sharings, "/member/sharings"

Tog::Plugins.settings :tog_core, {"site.name" => "Schoolarly"}, :force => true

Tog::Plugins.settings :tog_social, {"profile.image.versions.tiny"   => "35x35#"}, :force => true

Tog::Plugins.settings :tog_user,  {
    :email_as_login                   => true, 
    :default_redirect_on_login        => "/member",
    :default_redirect_on_logout       => "/",
    :default_redirect_on_signup       => "/",
    :default_redirect_on_activation   => "/member",
    :default_redirect_on_forgot       => "/",
    :default_redirect_on_reset        => "/"
}, :force => true

Tog::Plugins.settings :schoolarly, {
    "assignment.image.default"        => "dashboard/assignment2.png",
    "attachment.image.default"        => "dashboard/document2.png",
    "post.image.default"              => "dashboard/note2.png",
    "event.image.default"             => "dashboard/event2.png",
    "notice.image.default"            => "dashboard/notice2.png",
    "group.notebook.default"              => "Default notebook for group"
}, :force => true

Tog::Plugins.settings :schoolarly,  {
    'sanitized.allowed_tags'       => (Tog::Plugins.settings(:tog_core, 'sanitized.allowed_tags').to_a + %w( table tr td caption )).join(' '),
    'sanitized.allowed_attributes' => (Tog::Plugins.settings(:tog_core, 'sanitized.allowed_attributes').to_a + %w( style )).join(' '),
    'sanitized.comments.allowed_tags' => ActionView::Base.sanitized_allowed_tags.to_a.join(' '),
    'sanitized.comments.allowed_attributes' => ActionView::Base.sanitized_allowed_attributes.to_a.join(' ')
}, :force => true


if RAILS_ENV == 'production'
  Tog::Plugins.settings :tog_core, {"storage" => "S3"}, :force => true
  Tog::Plugins.settings :tog_core, {"storage.s3.path" => "/system/:class/:attachment/:id/:style_:basename.:extension"}, :force => true
  Tog::Plugins.settings :tog_core, {"storage.s3.bucket" => "Schoolarly"}, :force => true
  Tog::Plugins.settings :tog_core, {"storage.s3.access_key_id" => "AKIAIMQFQ2BSZ5X5SWFQ"}, :force => true
  Tog::Plugins.settings :tog_core, {"storage.s3.secret_access_key" => "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"}, :force => true
  Tog::Plugins.settings :tog_core, {"storage.s3.url" => "/system/:class/:attachment/:id/:style_:basename.:extension"}, :force => true
end