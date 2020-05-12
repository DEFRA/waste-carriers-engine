# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedPendingPaymentFormsController < FormsController
    include UnsubmittableForm
    include CannotGoBackForm

    helper JourneyLinksHelper

    def new
      super(RenewalReceivedPendingPaymentForm, "renewal_received_pending_payment_form")
    end
  end
end
