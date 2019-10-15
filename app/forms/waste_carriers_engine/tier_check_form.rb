# frozen_string_literal: true

module WasteCarriersEngine
  class TierCheckForm < BaseForm
    delegate :temp_tier_check, to: :transient_registration

    validates :temp_tier_check, "waste_carriers_engine/yes_no": true
  end
end
