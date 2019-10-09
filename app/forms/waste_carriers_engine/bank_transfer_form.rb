# frozen_string_literal: true

module WasteCarriersEngine
  class BankTransferForm < BaseForm
    attr_accessor :total_to_pay

    def self.can_navigate_flexibly?
      false
    end

    def initialize(transient_registration)
      super

      self.total_to_pay = transient_registration.total_to_pay
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      attributes = {}

      super(attributes, params[:reg_identifier])
    end
  end
end
