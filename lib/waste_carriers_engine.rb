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

  class Configuration
    # Companies house API config
    attr_reader :companies_house_host, :companies_house_api_key

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
  end
end
