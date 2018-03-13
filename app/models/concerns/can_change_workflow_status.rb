module CanChangeWorkflowStatus
  extend ActiveSupport::Concern
  include Mongoid::Document

  included do
    include AASM

    field :workflow_state, type: String

    aasm column: :workflow_state do
      # States / forms
      state :renewal_start_form, initial: true

      state :location_form
      state :register_in_northern_ireland_form
      state :register_in_scotland_form
      state :register_in_wales_form

      state :business_type_form

      state :other_businesses_form
      state :service_provided_form
      state :construction_demolition_form
      state :waste_types_form

      state :cbd_type_form
      state :renewal_information_form
      state :registration_number_form

      state :company_name_form
      state :company_postcode_form
      state :company_address_form
      state :company_address_manual_form

      state :key_people_form

      state :declare_convictions_form
      state :conviction_details_form

      state :contact_name_form
      state :contact_phone_form
      state :contact_email_form
      state :contact_address_form

      state :check_your_answers_form
      state :declaration_form
      state :payment_summary_form
      state :worldpay_form

      state :renewal_complete_form

      state :cannot_renew_lower_tier_form
      state :cannot_renew_type_change_form
      state :cannot_renew_company_no_change_form

      # Transitions
      event :next do
        transitions from: :renewal_start_form,
                    to: :location_form

        # Location

        transitions from: :location_form,
                    to: :business_type_form

        transitions from: :register_in_northern_ireland_form,
                    to: :business_type_form

        transitions from: :register_in_scotland_form,
                    to: :business_type_form

        transitions from: :register_in_wales_form,
                    to: :business_type_form

        # End location

        transitions from: :business_type_form,
                    to: :cannot_renew_lower_tier_form,
                    if: :switch_to_lower_tier_based_on_business_type?

        transitions from: :business_type_form,
                    to: :other_businesses_form,
                    if: :business_type_change_valid?

        transitions from: :business_type_form,
                    to: :cannot_renew_type_change_form

        # Smart answers

        transitions from: :other_businesses_form,
                    to: :construction_demolition_form,
                    if: :only_carries_own_waste?

        transitions from: :other_businesses_form,
                    to: :service_provided_form

        transitions from: :service_provided_form,
                    to: :waste_types_form,
                    if: :waste_is_main_service?

        transitions from: :service_provided_form,
                    to: :construction_demolition_form

        transitions from: :waste_types_form,
                    to: :cannot_renew_lower_tier_form,
                    if: :switch_to_lower_tier_based_on_smart_answers?

        transitions from: :waste_types_form,
                    to: :cbd_type_form

        transitions from: :construction_demolition_form,
                    to: :cannot_renew_lower_tier_form,
                    if: :switch_to_lower_tier_based_on_smart_answers?

        transitions from: :construction_demolition_form,
                    to: :cbd_type_form

        # End smart answers

        transitions from: :cbd_type_form,
                    to: :renewal_information_form

        transitions from: :renewal_information_form,
                    to: :company_name_form,
                    if: :skip_registration_number?

        transitions from: :renewal_information_form,
                    to: :registration_number_form

        transitions from: :registration_number_form,
                    to: :cannot_renew_company_no_change_form,
                    if: :require_new_registration_based_on_company_no?

        transitions from: :registration_number_form,
                    to: :company_name_form

        transitions from: :company_name_form,
                    to: :company_address_manual_form,
                    if: :overseas_address?

        transitions from: :company_name_form,
                    to: :company_postcode_form

        # Registered address

        transitions from: :company_postcode_form,
                    to: :company_address_manual_form,
                    if: :skip_to_manual_address?

        transitions from: :company_postcode_form,
                    to: :company_address_form

        transitions from: :company_address_form,
                    to: :company_address_manual_form,
                    if: :skip_to_manual_address?

        transitions from: :company_address_form,
                    to: :key_people_form

        transitions from: :company_address_manual_form,
                    to: :key_people_form

        # End registered address

        transitions from: :key_people_form,
                    to: :declare_convictions_form

        transitions from: :declare_convictions_form,
                    to: :conviction_details_form

        transitions from: :conviction_details_form,
                    to: :contact_name_form

        transitions from: :contact_name_form,
                    to: :contact_phone_form

        transitions from: :contact_phone_form,
                    to: :contact_email_form

        transitions from: :contact_email_form,
                    to: :contact_address_form

        transitions from: :contact_address_form,
                    to: :check_your_answers_form

        transitions from: :check_your_answers_form,
                    to: :declaration_form

        transitions from: :declaration_form,
                    to: :payment_summary_form

        transitions from: :payment_summary_form,
                    to: :worldpay_form

        transitions from: :worldpay_form,
                    to: :renewal_complete_form
      end

      event :back do
        # Location

        transitions from: :location_form,
                    to: :renewal_start_form

        transitions from: :register_in_northern_ireland_form,
                    to: :location_form

        transitions from: :register_in_scotland_form,
                    to: :location_form

        transitions from: :register_in_wales_form,
                    to: :location_form

        # End location

        transitions from: :business_type_form,
                    to: :location_form

        # Smart answers

        transitions from: :other_businesses_form,
                    to: :business_type_form

        transitions from: :service_provided_form,
                    to: :other_businesses_form

        transitions from: :waste_types_form,
                    to: :service_provided_form

        transitions from: :construction_demolition_form,
                    to: :other_businesses_form,
                    if: :only_carries_own_waste?

        transitions from: :construction_demolition_form,
                    to: :service_provided_form

        transitions from: :cbd_type_form,
                    to: :construction_demolition_form,
                    if: :only_carries_own_waste?

        transitions from: :cbd_type_form,
                    to: :waste_types_form,
                    if: :waste_is_main_service?

        transitions from: :cbd_type_form,
                    to: :construction_demolition_form

        # End smart answers

        transitions from: :renewal_information_form,
                    to: :cbd_type_form

        transitions from: :registration_number_form,
                    to: :renewal_information_form

        transitions from: :cannot_renew_company_no_change_form,
                    to: :registration_number_form

        transitions from: :company_name_form,
                    to: :renewal_information_form,
                    if: :skip_registration_number?

        transitions from: :company_name_form,
                    to: :registration_number_form

        # Registered address

        transitions from: :company_postcode_form,
                    to: :company_name_form

        transitions from: :company_address_form,
                    to: :company_postcode_form

        transitions from: :company_address_manual_form,
                    to: :company_name_form,
                    if: :overseas_address?

        transitions from: :company_address_manual_form,
                    to: :company_postcode_form

        transitions from: :key_people_form,
                    to: :company_address_manual_form,
                    if: :registered_address_was_manually_entered?

        transitions from: :key_people_form,
                    to: :company_address_form

        # End registered address

        transitions from: :declare_convictions_form,
                    to: :key_people_form

        transitions from: :conviction_details_form,
                    to: :declare_convictions_form

        transitions from: :contact_name_form,
                    to: :conviction_details_form

        transitions from: :contact_phone_form,
                    to: :contact_name_form

        transitions from: :contact_email_form,
                    to: :contact_phone_form

        transitions from: :contact_address_form,
                    to: :contact_email_form

        transitions from: :check_your_answers_form,
                    to: :contact_address_form

        transitions from: :declaration_form,
                    to: :check_your_answers_form

        transitions from: :payment_summary_form,
                    to: :declaration_form

        transitions from: :worldpay_form,
                    to: :payment_summary_form

        # Exit routes from renewals process

        transitions from: :cannot_renew_type_change_form,
                    to: :business_type_form

        transitions from: :cannot_renew_lower_tier_form,
                    to: :business_type_form,
                    if: :switch_to_lower_tier_based_on_business_type?

        transitions from: :cannot_renew_lower_tier_form,
                    to: :construction_demolition_form,
                    if: :only_carries_own_waste?

        transitions from: :cannot_renew_lower_tier_form,
                    to: :waste_types_form,
                    if: :waste_is_main_service?

        transitions from: :cannot_renew_lower_tier_form,
                    to: :construction_demolition_form
      end

      event :skip_to_manual_address do
        transitions from: :company_postcode_form,
                    to: :company_address_manual_form

        transitions from: :company_address_form,
                    to: :company_address_manual_form
      end
    end
  end

  private

  def skip_registration_number?
    %w[localAuthority overseas partnership soleTrader].include?(business_type)
  end

  # Charity registrations should be lower tier
  def switch_to_lower_tier_based_on_business_type?
    business_type == "charity"
  end

  def switch_to_lower_tier_based_on_smart_answers?
    return true if other_businesses == false && construction_waste == false
    return true if other_businesses == true && is_main_service == false && construction_waste == false
    return true if other_businesses == true && is_main_service == true && only_amf == true
    false
  end

  def require_new_registration_based_on_company_no?
    old_company_no = Registration.where(reg_identifier: reg_identifier).first.company_no.to_s
    # It was previously valid to have company_nos with less than 8 digits
    # The form prepends 0s to make up the length, so we should do this for the old number to match
    old_company_no = "0#{old_company_no}" while old_company_no.length < 8
    old_company_no != company_no
  end

  def only_carries_own_waste?
    other_businesses == false
  end

  def waste_is_main_service?
    is_main_service == true
  end

  def overseas_address?
    business_type == "overseas"
  end

  def registered_address_was_manually_entered?
    return unless registered_address
    registered_address.manually_entered?
  end

  def skip_to_manual_address?
    temp_os_places_error
  end
end
