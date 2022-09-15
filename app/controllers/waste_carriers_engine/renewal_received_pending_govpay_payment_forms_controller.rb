# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedPendingGovpayPaymentFormsController < ::WasteCarriersEngine::FormsController
    include CannotGoBackForm
    include UnsubmittableForm

    def new
      super(RenewalReceivedPendingGovpayPaymentForm, "renewal_received_pending_govpay_payment_form")
    end
  end
end
