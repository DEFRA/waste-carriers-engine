# frozen_string_literal: true

module RackLoggerMonkeyPatch

  def call(env)
    if should_suppress?(env["PATH_INFO"])
      Rails.logger.silence(Logger::WARN) { super }
    else
      super
    end
  end

  private

  # Suppress logging of heartbeat GETs as these are high volume and clutter the logs
  def should_suppress?(path)
    return false if WasteCarriersEngine::FeatureToggle.active?(:disable_rack_logger_filter)

    path&.match(/#{heartbeat_path}/).present?
  end

  def heartbeat_path
    @heartbeat_path ||= Rails.application.config.wcrs_logger_heartbeat_path
  end
end

Rails::Rack::Logger.prepend RackLoggerMonkeyPatch
