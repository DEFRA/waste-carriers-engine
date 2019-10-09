# frozen_string_literal: true

module WasteCarriersEngine
  class CompanyPostcodeForm < PostcodeForm
    delegate :business_type, :temp_company_postcode, to: :transient_registration

    validates :temp_company_postcode, "waste_carriers_engine/postcode": true

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      params[:temp_company_postcode] = format_postcode(params[:temp_company_postcode])

      # While we won't proceed if the postcode isn't valid, we always save it in case it's needed for manual entry
      transient_registration.update_attributes(params)

      super
    end
  end
end
