# frozen_string_literal: true

module WasteCarriersEngine
  module CanResetCompanyDetails
    extend ActiveSupport::Concern

    included do

      # Clear any previous business-type specific attributes to handle cases where the user
      # starts with one business type and then navigates back and changes the business type.
      def reset_company_attributes
        # The renewals flow has its own logic to handle such changes
        return unless @transient_registration.is_a?(NewRegistration)

        @transient_registration.company_no = nil
        @transient_registration.registered_company_name = nil
        @transient_registration.temp_use_registered_company_details = nil
        @transient_registration.save!
      end
    end
  end
end
