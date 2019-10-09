# frozen_string_literal: true

module WasteCarriersEngine
  class CompanyNameForm < BaseForm
    delegate :business_type, :company_name, to: :transient_registration

    validates :company_name, "waste_carriers_engine/company_name": true
  end
end
