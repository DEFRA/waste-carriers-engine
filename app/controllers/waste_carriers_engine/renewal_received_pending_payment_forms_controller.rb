# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedPendingPaymentFormsController < FormsController
    include UnsubmittableForm
    helper JourneyLinksHelper

    def new
      super(RenewalReceivedPendingPaymentForm, "renewal_received_pending_payment_form")
    end

    def go_back; end
  end
end
