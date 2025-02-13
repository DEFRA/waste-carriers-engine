# frozen_string_literal: true

module WasteCarriersEngine
  class DetailedLogger
    # Do not log anything unless detailed_logging is enabled.
    def self.fatal(*args)
      Rails.logger.fatal(*args) if detail_enabled?
    end

    def self.error(*args)
      Rails.logger.error(*args) if detail_enabled?
    end

    def self.warn(*args)
      Rails.logger.warn(*args) if detail_enabled?
    end

    def self.info(*args)
      Rails.logger.info(*args) if detail_enabled?
    end

    def self.debug(*args)
      Rails.logger.debug(*args) if detail_enabled?
    end

    def self.unknown(*args)
      Rails.logger.unknown(*args) if detail_enabled?
    end

    def self.detail_enabled?
      FeatureToggle.active?(:detailed_logging)
    end
  end
end
