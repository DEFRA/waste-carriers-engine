require "aasm"
require "mongoid"
# Must require Mongoid before CanCanCan for adaptors to work
require "cancancan"
require "devise"
require "high_voltage"

module WasteCarriersEngine
  class Engine < ::Rails::Engine
    isolate_namespace WasteCarriersEngine

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: "spec/factories"
      g.assets false
      g.helper false
    end

    # Load I18n translation files
    config.before_initialize do
      config.i18n.load_path += Dir["#{config.root}/config/locales/**/*.yml"]
    end
  end
end
