# frozen_string_literal: true

module WasteCarriersEngine
  class TransientRegistration
    include Mongoid::Document
    include CanCheckBusinessTypeChanges
    include CanCheckRegistrationStatus
    include CanFilterConvictionStatus
    include CanHaveRegistrationAttributes
    include CanHaveSecureToken
    include CanSetCreatedAt
    include CanStripWhitespace

    store_in collection: "transient_registrations"

    before_save :update_last_modified

    # Attributes specific to the transient object - all others are in CanHaveRegistrationAttributes
    field :temp_cards, type: Integer
    field :temp_company_postcode, type: String
    field :temp_contact_postcode, type: String
    field :temp_os_places_error, type: String # 'yes' or 'no' - should refactor to boolean
    field :temp_payment_method, type: String
    field :temp_tier_check, type: String # 'yes' or 'no' - should refactor to boolean

    scope :in_progress, -> { where(:workflow_state.nin => RenewingRegistration::SUBMITTED_STATES) }
    scope :submitted, -> { where(:workflow_state.in => RenewingRegistration::SUBMITTED_STATES) }
    scope :pending_payment, -> { submitted.where(:"financeDetails.balance".gt => 0) }
    scope :pending_approval, -> { submitted.where("conviction_sign_offs.0.confirmed": "no") }

    def total_to_pay
      charges = registration_type_base_charges
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

    def pending_manual_conviction_check?
      conviction_check_required?
    end

    def set_metadata_route
      metaData.route = Rails.configuration.metadata_route

      save
    end

    private

    def registration_type_base_charges
      [] # default. Override on STI objects where necessary.
    end
  end
end
