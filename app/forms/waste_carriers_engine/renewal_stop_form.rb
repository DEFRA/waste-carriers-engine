# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalStopForm < ::WasteCarriersEngine::BaseForm
    include CannotSubmit
  end
end
