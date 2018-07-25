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

    # Load files in lib in order to make them available to the parent apps.
    # By default models, controllers, helpers, routes, locale files
    # (config/locales/*) and tasks (lib/tasks/*) will get loaded from the engine
    # by rails. But if we add any custom directories like app/services,
    # app/workers, or in our case stuff in lib/waster_carriers_engine these
    # won't be. Hence we load them here.
    Dir.foreach(__dir__) do |item|
      next if item == "." or item == ".."
      next if File.directory? item
      next if item == "engine.rb"
      next if item == "version.rb"
      require_relative item
    end

  end
end
