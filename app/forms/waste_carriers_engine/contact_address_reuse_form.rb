# frozen_string_literal: true

module WasteCarriersEngine
  class ContactAddressReuseForm < ::WasteCarriersEngine::BaseForm

    delegate :temp_reuse_registered_address, to: :transient_registration
    delegate :registered_address, to: :transient_registration
    delegate :contact_address, to: :transient_registration

    validates :temp_reuse_registered_address, inclusion: { in: %w[yes no] }
  end
end
