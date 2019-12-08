# frozen_string_literal: true

module WasteCarriersEngine
  class CopyCardsBankTransferFormsController < FormsController
    include OrderCopyCardsPermissionChecks

    def new
      return unless super(CopyCardsBankTransferForm, "copy_cards_bank_transfer_form")

      set_up_finance_details
    end

    def create
      result = super(CopyCardsBankTransferForm, "copy_cards_bank_transfer_form")

      OrderCopyCardsCompletionService.run(@transient_registration) if result
    end

    private

    def set_up_finance_details
      @transient_registration.prepare_for_payment(:bank_transfer, current_user)
    end
  end
end
