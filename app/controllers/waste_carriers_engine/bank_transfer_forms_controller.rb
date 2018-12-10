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
      FinanceDetails.new_finance_details(@transient_registration, :bank_transfer, current_user)
    end
  end
end
