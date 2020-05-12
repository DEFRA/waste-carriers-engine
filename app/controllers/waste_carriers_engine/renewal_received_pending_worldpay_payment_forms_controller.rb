# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedPendingWorldpayPaymentFormsController < FormsController
    include CannotGoBackForm
    include UnsubmittableForm

    helper JourneyLinksHelper

    def new
      super(RenewalReceivedPendingWorldpayPaymentForm, "renewal_received_pending_worldpay_payment_form")
    end
  end
end
