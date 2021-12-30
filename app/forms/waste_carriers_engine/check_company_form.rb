# frozen_string_literal: true

module WasteCarriersEngine
  class CheckCompanyForm < ::WasteCarriersEngine::BaseForm
    delegate :temp_use_companies_house_details, to: :transient_registration

    validates :temp_use_companies_house_details, "waste_carriers_engine/yes_no": true
  end
end
