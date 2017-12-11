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

        # TODO: Add transitions
      end

      event :back do
        transitions from: :business_type_page,
                    to: :renewal_start_page

        # TODO: Add transitions
      end
    end
  end
end
