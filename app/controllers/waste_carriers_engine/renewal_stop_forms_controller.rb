# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalStopFormsController < ::WasteCarriersEngine::FormsController
    include UnsubmittableForm

    def new
      super(RenewalStopForm, "renewal_stop_form")
    end
  end
end
