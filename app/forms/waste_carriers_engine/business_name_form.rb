# frozen_string_literal: true

module WasteCarriersEngine
  class BusinessNameForm < ::WasteCarriersEngine::BaseForm
    delegate :business_type, :business_name, to: :transient_registration

    validates :business_name, "waste_carriers_engine/business_name": true
  end
end
