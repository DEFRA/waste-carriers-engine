# frozen_string_literal: true

module WasteCarriersEngine
  class MustRegisterInScotlandFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(MustRegisterInScotlandForm, "must_register_in_scotland_form")
    end
  end
end
