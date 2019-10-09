# frozen_string_literal: true

module WasteCarriersEngine
  class CbdTypeForm < BaseForm
    attr_accessor :registration_type

    validates :registration_type, "waste_carriers_engine/registration_type": true

    def initialize(transient_registration)
      super

      self.registration_type = transient_registration.registration_type
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.registration_type = params[:registration_type]
      attributes = { registration_type: registration_type }

      super(attributes, params[:reg_identifier])
    end
  end
end
