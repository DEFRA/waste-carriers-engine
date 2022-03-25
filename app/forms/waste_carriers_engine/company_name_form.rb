# frozen_string_literal: true

module WasteCarriersEngine
  class CompanyNameForm < ::WasteCarriersEngine::BaseForm
    delegate :business_type, :company_name, :registered_company_name, :tier, to: :transient_registration

    validates :company_name, "waste_carriers_engine/company_name": true

    def initialize(transient_registration)
      # Any existing company name should not be used for a registration renewal.
      if transient_registration.is_a?(WasteCarriersEngine::RenewingRegistration)
        transient_registration.company_name = nil
      end

      super(transient_registration)
    end
  end
end
