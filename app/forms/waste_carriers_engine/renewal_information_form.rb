module WasteCarriersEngine
  class RenewalInformationForm < BaseForm
    include CanNavigateFlexibly

    attr_accessor :type_change, :total_fee

    def initialize(transient_registration)
      super
      self.type_change = @transient_registration.registration_type_changed?
      self.total_fee = @transient_registration.fee_including_possible_type_change
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      attributes = {}

      super(attributes, params[:reg_identifier])
    end
  end
end
