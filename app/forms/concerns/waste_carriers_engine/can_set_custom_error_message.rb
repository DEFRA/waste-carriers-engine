# frozen_string_literal: true

module WasteCarriersEngine
  module CanSetCustomErrorMessage
    extend ActiveSupport::Concern

    included do
      def self.custom_error_messages(attribute, *errors)
        messages = {}

        errors.each do |error|
          messages[error] = I18n.t("activemodel.errors.models." \
                                   "waste_carriers_engine/#{form_name}" \
                                   ".attributes.#{attribute}.#{error}")
        end

        messages
      end

      def self.form_name
        name.split("::").last.underscore
      end
    end
  end
end
