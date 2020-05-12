# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedPendingConvictionFormsController < FormsController
    include UnsubmittableForm
    helper JourneyLinksHelper

    def new
      super(RenewalReceivedPendingConvictionForm, "renewal_received_pending_conviction_form")
    end

    def go_back; end
  end
end
