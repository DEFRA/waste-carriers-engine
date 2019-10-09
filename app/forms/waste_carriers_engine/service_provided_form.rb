# frozen_string_literal: true

module WasteCarriersEngine
  class ServiceProvidedForm < BaseForm
    attr_accessor :is_main_service

    validates :is_main_service, "waste_carriers_engine/yes_no": true

    def initialize(transient_registration)
      super

      self.is_main_service = transient_registration.is_main_service
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.is_main_service = params[:is_main_service]
      attributes = { is_main_service: is_main_service }

      super(attributes)
    end
  end
end
