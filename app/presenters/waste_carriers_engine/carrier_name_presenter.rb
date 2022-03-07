# frozen_string_literal: true

module WasteCarriersEngine
  # This is a minimal presenter using shared logic to return the presentation name for the carrier.
  class CarrierNamePresenter < BasePresenter
    include WasteCarriersEngine::CanPresentEntityDisplayName
  end
end
