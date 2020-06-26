# frozen_string_literal: true

module WasteCarriersEngine
  class CannotRenewLowerTierForm < ::WasteCarriersEngine::BaseForm
    include CannotSubmit
  end
end
