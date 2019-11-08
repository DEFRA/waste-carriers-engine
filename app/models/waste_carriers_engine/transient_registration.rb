# frozen_string_literal: true

module WasteCarriersEngine
  class TransientRegistration
    include Mongoid::Document
    include CanCheckBusinessTypeChanges
    include CanCheckRegistrationStatus
    include CanHaveRegistrationAttributes
    include CanStripWhitespace

    # TODO: Swap me with the base registration workflow for new registrations
    include CanUseRenewingRegistrationWorkflow

    store_in collection: "transient_registrations"

    before_save :update_last_modified

    # Attributes specific to the transient object - all others are in CanHaveRegistrationAttributes
    field :temp_cards, type: Integer
    field :temp_company_postcode, type: String
    field :temp_contact_postcode, type: String
    field :temp_os_places_error, type: String # 'yes' or 'no' - should refactor to boolean
    field :temp_payment_method, type: String
    field :temp_tier_check, type: String # 'yes' or 'no' - should refactor to boolean

    scope :in_progress, -> { where(:workflow_state.nin => %w[renewal_complete_form renewal_received_form]) }
    scope :submitted, -> { where(:workflow_state.in => %w[renewal_complete_form renewal_received_form]) }
    scope :pending_payment, -> { submitted.where(:"financeDetails.balance".gt => 0) }
    scope :pending_approval, -> { submitted.where("conviction_sign_offs.0.confirmed": "no") }

    scope :convictions_possible_match, -> { submitted.where("conviction_sign_offs.0.workflow_state": "possible_match") }
    scope :convictions_checks_in_progress, lambda {
      submitted.where("conviction_sign_offs.0.workflow_state": "checks_in_progress")
    }
    scope :convictions_approved, -> { submitted.where("conviction_sign_offs.0.workflow_state": "approved") }
    scope :convictions_rejected, -> { submitted.where("conviction_sign_offs.0.workflow_state": "rejected") }

    def total_to_pay
      charges = [Rails.configuration.renewal_charge]
      charges << Rails.configuration.type_change_charge if registration_type_changed?
      charges << total_registration_card_charge
      charges.sum
    end

    def total_registration_card_charge
      return 0 unless temp_cards.present?

      temp_cards * Rails.configuration.card_charge
    end

    def pending_payment?
      unpaid_balance?
    end

    def pending_worldpay_payment?
      return false unless finance_details.present? &&
                          finance_details.orders.present? &&
                          finance_details.orders.first.present?

      Order.valid_world_pay_status?(:pending, finance_details.orders.first.world_pay_status)
    end

    def pending_manual_conviction_check?
      conviction_check_required?
    end

    def set_metadata_route
      metaData.route = Rails.configuration.metadata_route

      save
    end
  end
end
