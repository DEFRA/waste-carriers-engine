module WasteCarriersEngine
  class ServiceProvidedForm < BaseForm
    include CanNavigateFlexibly

    attr_accessor :is_main_service

    def initialize(transient_registration)
      super
      self.is_main_service = @transient_registration.is_main_service
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.is_main_service = params[:is_main_service]
      attributes = { is_main_service: is_main_service }

      super(attributes, params[:reg_identifier])
    end

    validates :is_main_service, "waste_carriers_engine/yes_no": true
  end
end
