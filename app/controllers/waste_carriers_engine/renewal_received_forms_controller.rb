# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedFormsController < FormsController
    include UnsubmittableForm
    helper JourneyLinksHelper

    def new
      super(RenewalReceivedForm, "renewal_received_form")
    end

    def go_back; end
  end
end
