# frozen_string_literal: true

module WasteCarriersEngine
  class CheckYourAnswersForm < ::WasteCarriersEngine::BaseForm
    include CanLimitNumberOfMainPeople
    include CanLimitNumberOfRelevantPeople

    delegate :business_type, :company_name, :company_no, :contact_address, :contact_email, to: :transient_registration
    delegate :first_name, :last_name, :location, :main_people, :phone_number, to: :transient_registration
    delegate :registered_company_name, :registration_type, :relevant_people, :tier, to: :transient_registration
    delegate :temp_use_trading_name, :registered_address, :declared_convictions, to: :transient_registration
    delegate :lower_tier?, :upper_tier?, :company_no_required?, :company_name_required?, to: :transient_registration

    validates :business_type, "defra_ruby/validators/business_type": {
      allow_overseas: true,
      messages: custom_error_messages(:business_type, :inclusion)
    }
    validates :company_name, "waste_carriers_engine/company_name": true
    validates :company_no, presence: true, if: :company_no_required?
    validates :contact_address, "waste_carriers_engine/address": true

    validates :contact_email, "defra_ruby/validators/email": {
      messages: custom_error_messages(:contact_email, :blank, :invalid_format)
    }, unless: :back_office?
    validates_with OptionalEmailValidator, attributes: [:contact_email], if: :back_office?

    validates :declared_convictions, "waste_carriers_engine/yes_no": true, if: :upper_tier?
    validates :first_name, :last_name, "waste_carriers_engine/person_name": true
    validates :location, "defra_ruby/validators/location": {
      allow_overseas: true,
      messages: custom_error_messages(:location, :inclusion)
    }
    validates :phone_number, "defra_ruby/validators/phone_number": true
    validates :registered_address, "waste_carriers_engine/address": true
    validates :registration_type, "waste_carriers_engine/registration_type": true, if: :upper_tier?
    validate :business_type_change_valid?, if: :renewing_registration?

    validates_with KeyPeopleValidator

    after_initialize :valid

    def submit(_params)
      attributes = {}

      super(attributes)
    end

    def registration_type_changed?
      transient_registration.registration_type_changed?
    end

    def contact_name
      "#{first_name} #{last_name}"
    end

    private

    def renewing_registration?
      transient_registration.is_a?(WasteCarriersEngine::RenewingRegistration)
    end

    def valid
      valid?
    end

    def business_type_change_valid?
      return true if transient_registration.business_type_change_valid?

      errors.add(:business_type, :invalid_change)
      false
    end

    def back_office?
      WasteCarriersEngine.configuration.host_is_back_office?
    end
  end
end
