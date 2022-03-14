# frozen_string_literal: true

module WasteCarriersEngine
  class CompanyNameForm < ::WasteCarriersEngine::BaseForm
    delegate :business_type, :company_name, :registered_company_name, :tier, to: :transient_registration

    validates :company_name, "waste_carriers_engine/company_name": true
  end
end
