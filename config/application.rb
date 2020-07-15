require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
#require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Csvlint
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Use GA middleware
    if ENV['CSVLINT_ANALYTICS_KEY']
      config.middleware.use("Rack::GoogleAnalytics", :tracker => ENV['CSVLINT_ANALYTICS_KEY'])
    end

    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get]
      end
    end

    config.assets.precompile += %w{
      resumable.css
      html5shiv.js
      respond.min.js
      ie9.css
      ie8.css
      ie7.css
      ie6.css
      jquery.dotdotdot.js
    }

  end
end
