module CanChangeWorkflowStatus
  extend ActiveSupport::Concern
  include Mongoid::Document

  included do
    include AASM

    field :workflow_state, type: String

    aasm column: :workflow_state do
      # States / pages
      state :renewal_start, initial: true
      state :business_type
      state :smart_answers
      state :cbd_type
      state :renewal_information
      state :registration_number

      state :company_name
      state :company_postcode
      state :company_address

      state :key_people_director

      state :declare_convictions
      state :conviction_details

      state :contact_name
      state :contact_phone
      state :contact_email
      state :contact_address

      state :check_your_answers
      state :declaration
      state :payment_summary
      state :worldpay

      state :renewal_complete

      state :cannot_renew_type_change
      state :cannot_renew_unknown_type
      state :cannot_renew_should_be_lower
      state :cannot_renew_reg_number_change

      # Transitions
      event :next do
        transitions from: :renewal_start,
                    to: :business_type

        # TODO: Add transitions
      end

      event :back do
        transitions from: :business_type,
                    to: :renewal_start

        # TODO: Add transitions
      end
    end
  end
end
