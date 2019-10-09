# frozen_string_literal: true

module WasteCarriersEngine
  class DeclareConvictionsForm < BaseForm
    attr_accessor :declared_convictions

    validates :declared_convictions, "waste_carriers_engine/yes_no": true

    def initialize(transient_registration)
      super

      self.declared_convictions = transient_registration.declared_convictions
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.declared_convictions = params[:declared_convictions]
      attributes = { declared_convictions: declared_convictions }

      super(attributes)
    end
  end
end
