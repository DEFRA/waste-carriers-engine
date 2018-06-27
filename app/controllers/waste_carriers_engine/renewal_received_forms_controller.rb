# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedFormsController < FormsController
    def new
      super(RenewalReceivedForm, "renewal_received_form")
    end

    # Overwrite create and go_back as you shouldn't be able to submit or go back
    def create; end

    def go_back; end
  end
end
