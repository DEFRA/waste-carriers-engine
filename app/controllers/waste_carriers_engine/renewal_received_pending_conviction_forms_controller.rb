# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedPendingConvictionFormsController < FormsController
    include UnsubmittableForm
    include CannotGoBackForm

    helper JourneyLinksHelper

    def new
      super(RenewalReceivedPendingConvictionForm, "renewal_received_pending_conviction_form")
    end
  end
end
