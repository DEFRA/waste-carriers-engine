# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedPendingWorldpayPaymentFormsController < FormsController
    helper JourneyLinksHelper
    include UnsubmittableForm

    def new
      super(RenewalReceivedPendingWorldpayPaymentForm, "renewal_received_pending_worldpay_payment_form")
    end

    def go_back; end
  end
end
