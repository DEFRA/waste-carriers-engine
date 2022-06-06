# frozen_string_literal: true

module WasteCarriersEngine
  class TransientRegistration
    include Mongoid::Document
    include CanCheckBusinessTypeChanges
    include CanCheckRegistrationStatus
    include CanFilterConvictionStatus
    include CanHaveRegistrationAttributes
    include CanPresentEntityDisplayName
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
    field :temp_reuse_registered_address, type: String
    field :temp_use_registered_company_details, type: String
    field :workflow_history, type: Array, default: []

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

    def registration
      raise NotImplementedError
    end

    def next_state!
      previous_state = workflow_state
      next!
      workflow_history << previous_state unless previous_state.nil?
      save!
    rescue AASM::UndefinedState, AASM::InvalidTransition => e
      Airbrake.notify(e, reg_identifier) if defined?(Airbrake)
      Rails.logger.warn "Failed to transition to next workflow state, registration #{reg_identifier}: #{e}"
    end

    def previous_valid_state!
      return unless workflow_history&.length

      last_popped = nil
      until workflow_history.empty?
        last_popped = workflow_history.pop
        break if valid_state?(last_popped) && last_popped != workflow_state

        last_popped = nil
      end

      self.workflow_state = last_popped || "start_form"
      save!
    end

    private

    def valid_state?(state)
      return false unless state.present?

      valid_state_names.include? state.to_sym
    end

    def valid_state_names
      @valid_state_names ||= aasm.states.map(&:name)
    end

    def registration_type_base_charges
      [] # default. Override on STI objects where necessary.
    end
  end
end
