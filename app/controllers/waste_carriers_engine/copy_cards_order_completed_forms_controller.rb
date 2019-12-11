# frozen_string_literal: true

module WasteCarriersEngine
  class CopyCardsOrderCompletedFormsController < FormsController
    def new
      return unless super(CopyCardsOrderCompletedForm, "copy_cards_order_completed_form")

      OrderCopyCardsCompletionService.run(@transient_registration)
    end

    # Overwrite create and go_back as you shouldn't be able to submit or go back
    def create; end

    def go_back; end
  end
end
