# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedFormsController < ::WasteCarriersEngine::FormsController
    include UnsubmittableForm
    include CannotGoBackForm

    def new
      super(RenewalReceivedForm, "renewal_received_form")
    end
  end
end
