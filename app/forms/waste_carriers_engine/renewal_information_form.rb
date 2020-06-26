# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalInformationForm < ::WasteCarriersEngine::BaseForm
    attr_accessor :type_change, :total_fee

    def initialize(transient_registration)
      super

      self.type_change = transient_registration.registration_type_changed?
      self.total_fee = transient_registration.fee_including_possible_type_change
    end

    def submit(_params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      attributes = {}

      super(attributes)
    end
  end
end
