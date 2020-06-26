# frozen_string_literal: true

module WasteCarriersEngine
  class CeasedOrRevokedConfirmForm < ::WasteCarriersEngine::BaseForm
    delegate :contact_address, :company_name, :registration_type, :tier, to: :transient_registration
  end
end
