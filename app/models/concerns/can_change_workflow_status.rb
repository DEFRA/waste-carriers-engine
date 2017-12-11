module CanChangeWorkflowStatus
  extend ActiveSupport::Concern
  include Mongoid::Document

  included do
    include AASM

    field :workflow_state, type: String

    aasm column: :workflow_state do
      # States / pages
      state :renewal_start_page, initial: true
      state :business_type_page
      state :smart_answers_page
      state :cbd_type_page
      state :renewal_information_page
      state :registration_number_page

      state :company_name_page
      state :company_postcode_page
      state :company_address_page

      state :key_people_director_page

      state :declare_convictions_page
      state :conviction_details_page

      state :contact_name_page
      state :contact_phone_page
      state :contact_email_page
      state :contact_address_page

      state :check_your_answers_page
      state :declaration_page
      state :payment_summary_page
      state :worldpay_page

      state :renewal_complete_page

      state :cannot_renew_type_change_page
      state :cannot_renew_unknown_type_page
      state :cannot_renew_should_be_lower_page
      state :cannot_renew_reg_number_change_page

      # Transitions
      event :next do
        transitions from: :renewal_start_page,
                    to: :business_type_page

        transitions from: :business_type_page,
                    to: :smart_answers_page

        transitions from: :smart_answers_page,
                    to: :cbd_type_page

        transitions from: :cbd_type_page,
                    to: :renewal_information_page

        transitions from: :renewal_information_page,
                    to: :registration_number_page

        transitions from: :registration_number_page,
                    to: :company_name_page

        transitions from: :company_name_page,
                    to: :company_postcode_page

        transitions from: :company_postcode_page,
                    to: :company_address_page

        transitions from: :company_address_page,
                    to: :key_people_director_page

        transitions from: :key_people_director_page,
                    to: :declare_convictions_page

        transitions from: :declare_convictions_page,
                    to: :conviction_details_page

        transitions from: :conviction_details_page,
                    to: :contact_name_page

        transitions from: :contact_name_page,
                    to: :contact_phone_page

        transitions from: :contact_phone_page,
                    to: :contact_email_page

        transitions from: :contact_email_page,
                    to: :contact_address_page

        transitions from: :contact_address_page,
                    to: :check_your_answers_page

        transitions from: :check_your_answers_page,
                    to: :declaration_page

        transitions from: :declaration_page,
                    to: :payment_summary_page

        transitions from: :payment_summary_page,
                    to: :worldpay_page

        transitions from: :worldpay_page,
                    to: :renewal_complete_page
      end

      event :back do
        transitions from: :business_type_page,
                    to: :renewal_start_page

        transitions from: :smart_answers_page,
                    to: :business_type_page

        transitions from: :cbd_type_page,
                    to: :smart_answers_page

        transitions from: :renewal_information_page,
                    to: :cbd_type_page

        transitions from: :registration_number_page,
                    to: :renewal_information_page

        transitions from: :company_name_page,
                    to: :registration_number_page

        transitions from: :company_postcode_page,
                    to: :company_name_page

        transitions from: :company_address_page,
                    to: :company_postcode_page

        transitions from: :key_people_director_page,
                    to: :company_address_page

        transitions from: :declare_convictions_page,
                    to: :key_people_director_page

        transitions from: :conviction_details_page,
                    to: :declare_convictions_page

        transitions from: :contact_name_page,
                    to: :conviction_details_page

        transitions from: :contact_phone_page,
                    to: :contact_name_page

        transitions from: :contact_email_page,
                    to: :contact_phone_page

        transitions from: :contact_address_page,
                    to: :contact_email_page

        transitions from: :check_your_answers_page,
                    to: :contact_address_page

        transitions from: :declaration_page,
                    to: :check_your_answers_page

        transitions from: :payment_summary_page,
                    to: :declaration_page

        transitions from: :worldpay_page,
                    to: :payment_summary_page
      end
    end
  end
end
