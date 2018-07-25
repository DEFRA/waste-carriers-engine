module WasteCarriersEngine
  class WasteTypesForm < BaseForm
    include CanNavigateFlexibly

    attr_accessor :only_amf

    def initialize(transient_registration)
      super
      self.only_amf = @transient_registration.only_amf
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.only_amf = params[:only_amf]
      attributes = { only_amf: only_amf }

      super(attributes, params[:reg_identifier])
    end

    validates :only_amf, "waste_carriers_engine/yes_no": true
  end
end
