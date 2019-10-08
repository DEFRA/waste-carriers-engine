# frozen_string_literal: true

module WasteCarriersEngine
  class ConstructionDemolitionForm < BaseForm
    attr_accessor :construction_waste

    validates :construction_waste, "waste_carriers_engine/yes_no": true

    def initialize(transient_registration)
      super
      self.construction_waste = transient_registration.construction_waste
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.construction_waste = params[:construction_waste]
      attributes = { construction_waste: construction_waste }

      super(attributes, params[:reg_identifier])
    end
  end
end
