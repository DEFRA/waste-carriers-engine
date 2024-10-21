# frozen_string_literal: true

module WasteCarriersEngine
  class ConfirmBankTransferFormsController < ::WasteCarriersEngine::FormsController
    def new
      return unless super(ConfirmBankTransferForm, "confirm_bank_transfer_form")

      set_up_finance_details
    end

    def create
      super(ConfirmBankTransferForm, "confirm_bank_transfer_form")
    end

    private

    def set_up_finance_details
      @transient_registration.prepare_for_payment(:bank_transfer)
    end
  end
end
