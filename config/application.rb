require File.expand_path('../boot', __FILE__)

require "active_model/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WasteCarriersRenewals
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    # config.i18n.default_locale = :de

    # Enable the asset pipeline
    config.assets.enabled = true

    config.assets.precompile += %w(
      application.css
      print.css
    )

    # Don't add field_with_errors div wrapper around fields with errors
    config.action_view.field_error_proc = proc { |html_tag, _instance|
      "#{html_tag}".html_safe
    }

    # Errbit config
    config.airbrake_on = ENV["WCRS_RENEWALS_USE_AIRBRAKE"] == "true" ? true : false
    config.airbrake_host = ENV["WCRS_RENEWALS_AIRBRAKE_HOST"]
    config.airbrake_id = ENV["WCRS_RENEWALS_AIRBRAKE_PROJECT_ID"]
    config.airbrake_key = ENV["WCRS_RENEWALS_AIRBRAKE_PROJECT_KEY"]

    # Companies House config
    config.companies_house_api_key = ENV["WCRS_RENEWALS_COMPANIES_HOUSE_API_KEY"]

    # Paths
    config.wcrs_frontend_url = ENV["WCRS_FRONTEND_PUBLIC_APP_DOMAIN"] || "localhost:3000"
    config.os_places_service_url = ENV["WCRS_RENEWALS_OS_PLACES_SERVICE_DOMAIN"] || "localhost:9190"

    # Fees
    config.renewal_charge = ENV["WCRS_RENEWAL_CHARGE"].to_i || 0
    config.type_change_charge = ENV["WCRS_TYPE_CHANGE_CHARGE"].to_i || 0

    # Times
    config.renewal_window = ENV["WCRS_REGISTRATION_RENEWAL_WINDOW"].to_i
    config.expires_after = ENV["WCRS_REGISTRATION_EXPIRES_AFTER"].to_i

    # Version info
    config.application_version = "0.0.1".freeze
    config.application_name = "waste-carriers-renewals"
    config.git_repository_url = "https://github.com/DEFRA/#{config.application_name}"
  end
end
