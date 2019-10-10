# frozen_string_literal: true

module WasteCarriersEngine
  class ServiceProvidedForm < BaseForm
    delegate :is_main_service, to: :transient_registration

    validates :is_main_service, "waste_carriers_engine/yes_no": true
  end
end
