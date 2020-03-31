# frozen_string_literal: true

module WasteCarriersEngine
  class RenewRegistrationForm < BaseForm
    delegate :temp_lookup_number, to: :transient_registration

    validates_with RenewalLookupValidator

    def submit(params)
      params[:temp_lookup_number].upcase! if params[:temp_lookup_number].present?

      super
    end
  end
end
