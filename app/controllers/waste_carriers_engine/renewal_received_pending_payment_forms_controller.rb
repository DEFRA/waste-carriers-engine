# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedPendingPaymentFormsController < ::WasteCarriersEngine::FormsController
    include UnsubmittableForm
    include CannotGoBackForm

    def new
      super(RenewalReceivedPendingPaymentForm, "renewal_received_pending_payment_form")
    end
  end
end
