# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedPendingOnlinePaymentFormsController < ::WasteCarriersEngine::FormsController
    include CannotGoBackForm
    include UnsubmittableForm

    def new
      super(RenewalReceivedPendingOnlinePaymentForm, "renewal_received_pending_online_payment_form")
    end
  end
end
