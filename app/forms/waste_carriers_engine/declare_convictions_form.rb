# frozen_string_literal: true

module WasteCarriersEngine
  class DeclareConvictionsForm < BaseForm
    delegate :declared_convictions, to: :transient_registration

    validates :declared_convictions, "waste_carriers_engine/yes_no": true
  end
end
