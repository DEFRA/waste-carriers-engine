# frozen_string_literal: true

module WasteCarriersEngine
  class CeasedOrRevokedConfirmForm < ::WasteCarriersEngine::BaseForm
    delegate :contact_address, :business_name, :registration_type, :tier, to: :transient_registration
  end
end
