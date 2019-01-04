# frozen_string_literal: true

module WasteCarriersEngine
  class OtherBusinessesForm < BaseForm
    include CanNavigateFlexibly

    attr_accessor :other_businesses

    def initialize(transient_registration)
      super
      self.other_businesses = @transient_registration.other_businesses
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.other_businesses = params[:other_businesses]
      attributes = { other_businesses: other_businesses }

      super(attributes, params[:reg_identifier])
    end

    validates :other_businesses, "waste_carriers_engine/yes_no": true
  end
end
