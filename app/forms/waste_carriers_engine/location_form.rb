# frozen_string_literal: true

module WasteCarriersEngine
  class LocationForm < BaseForm
    delegate :location, to: :transient_registration

    validates :location, "defra_ruby/validators/location": {
      allow_overseas: true,
      messages: custom_error_messages(:location, :inclusion)
    }

    def submit(params)
      # Set the business type to overseas when required as we use this for microcopy
      params[:business_type] = "overseas" if params[:location] == "overseas"

      super
    end
  end
end
