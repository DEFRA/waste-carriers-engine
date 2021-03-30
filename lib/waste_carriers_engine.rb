# frozen_string_literal: true

require "waste_carriers_engine/engine"

module WasteCarriersEngine
  # Enable the ability to configure the gem from its host app, rather than
  # reading directly from env vars. Derived from
  # https://robots.thoughtbot.com/mygem-configure-block
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end
  end

  def self.configure
    yield(configuration)
  end

  def self.start_airbrake
    DefraRuby::Alert.start
  end

  class Configuration
    # AD config
    attr_accessor :assisted_digital_email
    # Link to dashboard from user journeys
    attr_accessor :link_from_journeys_to_dashboards
    # Companies house API config
    attr_reader :companies_house_host, :companies_house_api_key
    # Address lookup config
    attr_reader :address_host
    # Notify config
    attr_accessor :notify_api_key

    def initialize
      configure_airbrake_rails_properties
    end

    def companies_house_host=(value)
      DefraRuby::Validators.configure do |configuration|
        configuration.companies_house_host = value
      end
    end

    def companies_house_api_key=(value)
      DefraRuby::Validators.configure do |configuration|
        configuration.companies_house_api_key = value
      end
    end

    def address_host=(value)
      @address_host = value
      DefraRuby::Address.configure do |configuration|
        configuration.host = value
      end
    end

    # Airbrake configuration properties (via defra_ruby_alert gem)
    def airbrake_enabled=(value)
      DefraRuby::Alert.configure do |configuration|
        configuration.enabled = change_string_to_boolean_for(value)
      end
    end

    def airbrake_host=(value)
      DefraRuby::Alert.configure do |configuration|
        configuration.host = value
      end
    end

    def airbrake_project_key=(value)
      DefraRuby::Alert.configure do |configuration|
        configuration.project_key = value
      end
    end

    def airbrake_blocklist=(value)
      DefraRuby::Alert.configure do |configuration|
        configuration.blocklist = value
      end
    end

    # Last Email caching and retrieval functionality
    def use_last_email_cache=(value)
      DefraRubyEmail.configure do |configuration|
        configuration.enable = change_string_to_boolean_for(value)
      end
    end

    # Used to determine if engine is running in the back-office rather than the
    # front-office
    def host_is_back_office=(value)
      @host_is_back_office = change_string_to_boolean_for(value)
    end

    def host_is_back_office?
      return false unless @host_is_back_office

      @host_is_back_office
    end

    private

    # If the setting's value is "true", then set to a boolean true. Otherwise,
    # set it to false.
    def change_string_to_boolean_for(setting)
      setting = setting == "true" if setting.is_a?(String)
      setting
    end

    def configure_airbrake_rails_properties
      DefraRuby::Alert.configure do |configuration|
        configuration.root_directory = Rails.root
        configuration.logger = Rails.logger
        configuration.environment = Rails.env
      end
    end
  end
end
