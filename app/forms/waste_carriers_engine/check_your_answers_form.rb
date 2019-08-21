# frozen_string_literal: true

module WasteCarriersEngine
  class CheckYourAnswersForm < BaseForm
    include CanLimitNumberOfMainPeople
    include CanLimitNumberOfRelevantPeople

    attr_accessor :business_type, :company_name, :company_no, :contact_address, :contact_email,
                  :declared_convictions, :first_name, :last_name, :location, :main_people, :phone_number,
                  :registered_address, :registration_type, :relevant_people, :tier

    def initialize(transient_registration)
      super
      self.business_type = @transient_registration.business_type
      self.company_name = @transient_registration.company_name
      self.company_no = @transient_registration.company_no
      self.contact_address = @transient_registration.contact_address
      self.contact_email = @transient_registration.contact_email
      self.declared_convictions = @transient_registration.declared_convictions
      self.first_name = @transient_registration.first_name
      self.last_name = @transient_registration.last_name
      self.location = @transient_registration.location
      self.main_people = @transient_registration.main_people
      self.phone_number = @transient_registration.phone_number
      self.registered_address = @transient_registration.registered_address
      self.registration_type = @transient_registration.registration_type
      self.relevant_people = @transient_registration.relevant_people
      self.tier = @transient_registration.tier

      valid?
    end

    def submit(params)
      attributes = {}

      super(attributes, params[:reg_identifier])
    end

    def registration_type_changed?
      @transient_registration.registration_type_changed?
    end

    def contact_name
      "#{first_name} #{last_name}"
    end

    validates :business_type, "defra_ruby/validators/business_type": {
      allow_overseas: true,
      messages: {
        inclusion: I18n.t("activemodel.errors.models.waste_carriers_engine/check_your_answers_form"\
                          ".attributes.business_type.inclusion")
      }
    }
    validates :company_name, "waste_carriers_engine/company_name": true
    validates :company_no, "defra_ruby/validators/companies_house_number": true, if: :company_no_required?
    validates :contact_address, "waste_carriers_engine/address": true
    validates :contact_email, "waste_carriers_engine/email": true
    validates :declared_convictions, "waste_carriers_engine/yes_no": true
    validates :first_name, :last_name, "waste_carriers_engine/person_name": true
    validates :location, "waste_carriers_engine/location": true
    validates :phone_number, "defra_ruby/validators/phone_number": true
    validates :registered_address, "waste_carriers_engine/address": true
    validates :registration_type, "waste_carriers_engine/registration_type": true
    validate :should_be_renewed

    validates_with KeyPeopleValidator

    private

    def should_be_renewed
      business_type_change_valid? && same_company_no?
    end

    def business_type_change_valid?
      return true if @transient_registration.business_type_change_valid?

      errors.add(:business_type, :invalid_change)
      false
    end

    def same_company_no?
      return true unless @transient_registration.company_no_changed?

      errors.add(:company_no, :changed)
      false
    end

    def company_no_required?
      @transient_registration.company_no_required?
    end
  end
end
