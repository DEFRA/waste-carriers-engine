# frozen_string_literal: true

require "yaml"
require "erb"

module WasteCarriersEngine
  class FeatureToggle
    def self.active?(feature_name)
      feature_toggles[feature_name] && (
        feature_toggles[feature_name][:active] == true ||
        feature_toggles[feature_name][:active] == "true"
      )
    end

    class << self
      private

      # rubocop:disable Style/ClassVars
      def feature_toggles
        @@feature_toggles ||= load_feature_toggles
      end
      # rubocop:enable Style/ClassVars

      def load_feature_toggles
        HashWithIndifferentAccess.new(YAML.safe_load(ERB.new(File.read(file_path)).result))
      end

      def file_path
        Rails.root.join("config/feature_toggles.yml")
      end
    end
  end
end
