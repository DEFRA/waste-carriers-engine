module WasteCarriersEngine
  class CompanyPostcodeForm < PostcodeForm
    include CanNavigateFlexibly

    attr_accessor :business_type, :temp_company_postcode

    def initialize(transient_registration)
      super
      self.temp_company_postcode = @transient_registration.temp_company_postcode
      # We only use this for the correct microcopy
      self.business_type = @transient_registration.business_type
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.temp_company_postcode = format_postcode(params[:temp_company_postcode])
      attributes = { temp_company_postcode: temp_company_postcode }

      # While we won't proceed if the postcode isn't valid, we should always save it in case it's needed for manual entry
      @transient_registration.update_attributes(attributes)

      super(attributes, params[:reg_identifier])
    end

    validates :temp_company_postcode, "waste_carriers_engine/postcode": true
  end
end
