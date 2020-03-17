# frozen_string_literal: true

module WasteCarriersEngine
  module CanCheckIfRegistrationTypeChanged
    extend ActiveSupport::Concern

    included do
      # Check if the user has changed the registration type, as this incurs an additional 40GBP charge
      def registration_type_changed?
        # Don't compare registration types if the new one hasn't been set
        return false unless registration_type

        registration.registration_type != registration_type
      end
    end
  end
end
