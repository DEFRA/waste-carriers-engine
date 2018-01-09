module CanChangeWorkflowStatus
  extend ActiveSupport::Concern
  include Mongoid::Document

  included do
    include AASM

    field :workflow_state, type: String

    aasm column: :workflow_state do
      # States / forms
      state :renewal_start_form, initial: true
      state :business_type_form
      state :smart_answers_form
      state :cbd_type_form
      state :renewal_information_form
      state :registration_number_form

      state :company_name_form
      state :company_postcode_form
      state :company_address_form

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
      state :cannot_renew_reg_number_change_form

      # Transitions
      event :next do
        transitions from: :renewal_start_form,
                    to: :business_type_form

        transitions from: :business_type_form,
                    to: :cannot_renew_lower_tier_form,
                    if: :switch_to_lower_tier?

        transitions from: :business_type_form,
                    to: :smart_answers_form,
                    if: :business_type_change_valid?

        transitions from: :business_type_form,
                    to: :cannot_renew_type_change_form

        transitions from: :smart_answers_form,
                    to: :cbd_type_form

        transitions from: :cbd_type_form,
                    to: :renewal_information_form

        transitions from: :renewal_information_form,
                    to: :company_name_form,
                    if: :skip_registration_number?

        transitions from: :renewal_information_form,
                    to: :registration_number_form

        transitions from: :registration_number_form,
                    to: :company_name_form

        transitions from: :company_name_form,
                    to: :company_postcode_form

        transitions from: :company_postcode_form,
                    to: :company_address_form

        transitions from: :company_address_form,
                    to: :key_people_form

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
        transitions from: :business_type_form,
                    to: :renewal_start_form

        transitions from: :smart_answers_form,
                    to: :business_type_form

        transitions from: :cbd_type_form,
                    to: :smart_answers_form

        transitions from: :renewal_information_form,
                    to: :cbd_type_form

        transitions from: :registration_number_form,
                    to: :renewal_information_form

        transitions from: :company_name_form,
                    to: :renewal_information_form,
                    if: :skip_registration_number?

        transitions from: :company_name_form,
                    to: :registration_number_form

        transitions from: :company_postcode_form,
                    to: :company_name_form

        transitions from: :company_address_form,
                    to: :company_postcode_form

        transitions from: :key_people_form,
                    to: :company_address_form

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

        transitions from: :cannot_renew_lower_tier_form,
                    to: :business_type_form

        transitions from: :cannot_renew_type_change_form,
                    to: :business_type_form
      end
    end
  end

  private

  def skip_registration_number?
    %w[localAuthority soleTrader].include?(business_type)
  end

  # Charity registrations should be lower tier
  def switch_to_lower_tier?
    business_type == "other"
  end
end
