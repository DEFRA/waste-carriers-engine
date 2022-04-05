# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedPendingCardPaymentFormsController < ::WasteCarriersEngine::FormsController
    include CannotGoBackForm
    include UnsubmittableForm

    def new
      super(RenewalReceivedPendingCardPaymentForm, "renewal_received_pending_card_payment_form")
    end
  end
end
