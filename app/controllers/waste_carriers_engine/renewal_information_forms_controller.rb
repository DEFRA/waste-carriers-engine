# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalInformationFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(RenewalInformationForm, "renewal_information_form")
    end

    def create
      super(RenewalInformationForm, "renewal_information_form")
    end
  end
end
