# frozen_string_literal: true

module WasteCarriersEngine
  class RenewRegistrationForm < BaseForm
    delegate :temp_lookup_number, to: :transient_registration

    validates_with RenewalLookupValidator
  end
end
