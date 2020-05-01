# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedPendingConvictionFormsController < FormsController
    helper JourneyLinksHelper

    def new
      super(RenewalReceivedPendingConvictionForm, "renewal_received_pending_conviction_form")
    end

    # Overwrite create and go_back as you shouldn't be able to submit or go back
    def create; end

    def go_back; end
  end
end
