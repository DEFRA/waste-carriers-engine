# frozen_string_literal: true

module WasteCarriersEngine
  class ConstructionDemolitionForm < ::WasteCarriersEngine::BaseForm
    delegate :construction_waste, to: :transient_registration

    validates :construction_waste, "waste_carriers_engine/yes_no": true
  end
end
