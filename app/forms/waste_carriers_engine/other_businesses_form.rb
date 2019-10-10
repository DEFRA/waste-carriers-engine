# frozen_string_literal: true

module WasteCarriersEngine
  class OtherBusinessesForm < BaseForm
    delegate :other_businesses, to: :transient_registration

    validates :other_businesses, "waste_carriers_engine/yes_no": true
  end
end
