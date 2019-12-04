# frozen_string_literal: true

module WasteCarriersEngine
  class BankTransferFormsController < FormsController
    def new
      return unless super(BankTransferForm, "bank_transfer_form")

      set_up_finance_details
    end

    def create
      super(BankTransferForm, "bank_transfer_form")
    end

    private

    def set_up_finance_details
      @transient_registration.prepare_for_payment(:bank_transfer, current_user)
    end

    def transient_registration_attributes
      # TODO: Remvoe when default empty params
      # Nothing to submit
      params.fetch(:bank_transfer_form).permit
    end
  end
end
