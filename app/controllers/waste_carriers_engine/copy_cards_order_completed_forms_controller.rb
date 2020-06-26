# frozen_string_literal: true

module WasteCarriersEngine
  class CopyCardsOrderCompletedFormsController < ::WasteCarriersEngine::FormsController
    include UnsubmittableForm
    include CannotGoBackForm

    def new
      return unless super(CopyCardsOrderCompletedForm, "copy_cards_order_completed_form")

      OrderCopyCardsCompletionService.run(@transient_registration)
    end
  end
end
