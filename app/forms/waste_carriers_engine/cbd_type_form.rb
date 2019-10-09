# frozen_string_literal: true

module WasteCarriersEngine
  class CbdTypeForm < BaseForm
    delegate :registration_type, to: :transient_registration

    validates :registration_type, "waste_carriers_engine/registration_type": true
  end
end
