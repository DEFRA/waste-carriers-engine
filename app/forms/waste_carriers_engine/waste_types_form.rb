# frozen_string_literal: true

module WasteCarriersEngine
  class WasteTypesForm < ::WasteCarriersEngine::BaseForm
    delegate :only_amf, to: :transient_registration

    validates :only_amf, "waste_carriers_engine/yes_no": true
  end
end
