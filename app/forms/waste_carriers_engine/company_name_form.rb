# frozen_string_literal: true

module WasteCarriersEngine
  class CompanyNameForm < BaseForm
    attr_accessor :business_type, :company_name

    validates :company_name, "waste_carriers_engine/company_name": true

    def initialize(transient_registration)
      super
      # We only use this for the correct microcopy
      self.business_type = transient_registration.business_type
      self.company_name = transient_registration.company_name
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.company_name = params[:company_name]
      attributes = { company_name: company_name }

      super(attributes, params[:reg_identifier])
    end
  end
end
