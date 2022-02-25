# frozen_string_literal: true

module WasteCarriersEngine
  class CheckRegisteredCompanyNameForm < ::WasteCarriersEngine::BaseForm
    delegate :temp_use_registered_company_details, to: :transient_registration

    validates :temp_use_registered_company_details, "waste_carriers_engine/yes_no": true
  end
end
