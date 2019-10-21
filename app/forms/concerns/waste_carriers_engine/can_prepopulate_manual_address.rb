# frozen_string_literal: true

module WasteCarriersEngine
  module CanPrepopulateManualAddress
    extend ActiveSupport::Concern

    included do
      delegate :business_is_overseas?, to: :transient_registration

      after_initialize :clean_address, unless: :saved_address_still_valid?

      def clean_address
        # Prefill the existing address unless the postcode has changed from the existing address's postcode
        transient_registration.company_address = Address.new(postcode: transient_registration.temp_company_postcode)
      end

      def saved_address_still_valid?
        temp_postcode = transient_registration.temp_company_postcode

        business_is_overseas? || temp_postcode.nil? || temp_postcode == postcode
      end
    end
  end
end
