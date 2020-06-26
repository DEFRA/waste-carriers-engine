# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedPendingConvictionFormsController < ::WasteCarriersEngine::FormsController
    include UnsubmittableForm
    include CannotGoBackForm

    def new
      super(RenewalReceivedPendingConvictionForm, "renewal_received_pending_conviction_form")
    end
  end
end
