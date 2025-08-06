# frozen_string_literal: true

module WasteCarriersEngine
  class DetailedLogger
    # Do not log anything unless detailed_logging is enabled.
    def self.fatal(*)
      Rails.logger.fatal(*) if detail_enabled?
    end

    def self.error(*)
      Rails.logger.error(*) if detail_enabled?
    end

    def self.warn(*)
      Rails.logger.warn(*) if detail_enabled?
    end

    def self.info(*)
      Rails.logger.info(*) if detail_enabled?
    end

    def self.debug(*)
      Rails.logger.debug(*) if detail_enabled?
    end

    def self.unknown(*)
      Rails.logger.unknown(*) if detail_enabled?
    end

    def self.detail_enabled?
      FeatureToggle.active?(:detailed_logging)
    end
  end
end
