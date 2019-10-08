# frozen_string_literal: true

module WasteCarriersEngine
  class LocationForm < BaseForm
    attr_accessor :location

    def initialize(transient_registration)
      super
      self.location = @transient_registration.location
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.location = params[:location]
      attributes = { location: location }

      # Set the business type to overseas when required as we use this for microcopy
      attributes[:business_type] = "overseas" if location == "overseas"

      super(attributes)
    end

    validates :location, "defra_ruby/validators/location": { allow_overseas: true }
  end
end
