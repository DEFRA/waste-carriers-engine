# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalCompleteFormsController < FormsController
    include UnsubmittableForm
    include CannotGoBackForm

    helper JourneyLinksHelper

    def new
      return unless super(RenewalCompleteForm, "renewal_complete_form")

      begin
        renewal_completion_service = RenewalCompletionService.new(@transient_registration)
        renewal_completion_service.complete_renewal
      rescue StandardError => e
        Airbrake.notify(e, reg_identifier: @transient_registration.reg_identifier)
        Rails.logger.error e
      end
    end
  end
end
