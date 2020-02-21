# frozen_string_literal: true

require "aasm"
require "mongoid"
require "high_voltage"
require "defra_ruby/alert"
require "defra_ruby_email"
require "defra_ruby_validators"

module WasteCarriersEngine
  class Engine < ::Rails::Engine
    isolate_namespace WasteCarriersEngine

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: "spec/factories"
      g.assets false
      g.helper false
    end

    config.autoload_paths << "#{config.root}/app/forms/concerns"
    config.autoload_paths << "#{config.root}/app/services/concerns"

    # Load I18n translation files from engine before loading ones from the host app
    # This means values in the host app can override those in the engine
    config.before_initialize do
      engine_locales = Dir["#{config.root}/config/locales/**/*.yml"]
      config.i18n.load_path = engine_locales + config.i18n.load_path
    end
  end
end
