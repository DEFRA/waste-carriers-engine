# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedPendingPaymentFormsController < FormsController
    helper JourneyLinksHelper

    def new
      super(RenewalReceivedPendingPaymentForm, "renewal_received_pending_payment_form")
    end

    # Overwrite create and go_back as you shouldn't be able to submit or go back
    def create; end

    def go_back; end
  end
end
