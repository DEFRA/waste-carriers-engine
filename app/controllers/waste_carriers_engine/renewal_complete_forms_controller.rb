# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalCompleteFormsController < FormsController
    helper JourneyLinksHelper

    def new
      return unless super(RenewalCompleteForm, "renewal_complete_form")

      renewal_completion_service = RenewalCompletionService.new(@transient_registration)
      renewal_completion_service.complete_renewal
    end

    # Overwrite create and go_back as you shouldn't be able to submit or go back
    def create; end

    def go_back; end
  end
end
