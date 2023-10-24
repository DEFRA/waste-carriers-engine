# frozen_string_literal: true

module WasteCarriersEngine
  class MustRegisterInWalesFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(MustRegisterInWalesForm, "must_register_in_wales_form")
    end
  end
end
