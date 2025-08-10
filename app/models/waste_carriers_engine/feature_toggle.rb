# frozen_string_literal: true

require "yaml"
require "erb"

module WasteCarriersEngine
  class FeatureToggle
    include Mongoid::Document

    # Use the FeatureToggles database
    store_in collection: "feature_toggles"

    field :key, type: String
    field :active, type: Boolean, default: false

    def self.active?(feature_name)
      from_database = where(key: feature_name).first

      return from_file(feature_name) unless from_database.present?

      from_database.active
    end

    class << self
      private

      def feature_toggles
        @feature_toggles ||= load_feature_toggles
      end

      def from_file(feature_name)
        feature_toggles[feature_name] && [true, "true"].include?(feature_toggles[feature_name][:active])
      end

      def load_feature_toggles
        HashWithIndifferentAccess.new(YAML.safe_load(ERB.new(File.read(file_path)).result))
      end

      def file_path
        Rails.root.join("config/feature_toggles.yml")
      end

      # Allow reloading of toggle settings
      # This is to support unit testing of environment-variable-based settings
      def reload_feature_toggles
        @feature_toggles = nil
      end
    end
  end
end
