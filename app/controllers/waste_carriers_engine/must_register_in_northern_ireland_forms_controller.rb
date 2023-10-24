# frozen_string_literal: true

module WasteCarriersEngine
  class MustRegisterInNorthernIrelandFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(MustRegisterInNorthernIrelandForm, "must_register_in_northern_ireland_form")
    end
  end
end
