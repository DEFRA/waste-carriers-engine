# frozen_string_literal: true

module WasteCarriersEngine
  class EditRegistration < TransientRegistration
    validates :reg_identifier, "waste_carriers_engine/reg_identifier": true
  end
end
