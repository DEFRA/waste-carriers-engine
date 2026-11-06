# frozen_string_literal: true

module WasteCarriersEngine
  class DuplicateCompanyRegistrationValidator < ActiveModel::Validator
    def validate(record)
      return unless should_validate?(record)
      return unless existing_active_upper_tier_registration?(record.company_no)

      record.errors.add(:company_no, :already_registered)
    end

    private

    def should_validate?(record)
      return false if WasteCarriersEngine.configuration.host_is_back_office?
      return false unless record.transient_registration.is_a?(NewRegistration)

      record.company_no.present?
    end

    def existing_active_upper_tier_registration?(company_no)
      Registration
        .where(company_no: company_no)
        .upper_tier
        .active
        .exists?
    end
  end
end
