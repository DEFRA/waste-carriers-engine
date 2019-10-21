# frozen_string_literal: true

module WasteCarriersEngine
  module CanClearAddressFinderError
    extend ActiveSupport::Concern

    included do
      attr_accessor :os_places_error

      after_initialize :clear_temp_os_places_error

      private

      # Check if the user reached this page through an Address finder error.
      # Then wipe the temp attribute as we only need it for routing
      def clear_temp_os_places_error
        self.os_places_error = transient_registration.temp_os_places_error

        transient_registration.update_attributes(temp_os_places_error: nil)
      end
    end
  end
end
