# frozen_string_literal: true

module WasteCarriersEngine
  module CanChangeRegistrationStatus
    extend ActiveSupport::Concern
    include Mongoid::Document
    include CanCalculateRenewalDates

    # The pattern for denoting events here is common when using AASM, however it
    # does mean we get flagged by rubocop. We don't want to change the rule at a
    # global level, but the excessive block length is acceptable here hence
    # we're happy to addthis exception
    # rubocop:disable Metrics/BlockLength
    included do
      include AASM

      field :status, type: String

      aasm column: :status do
        # States must be capitalised to match what waste-carriers-service adds to the database
        state :PENDING, initial: true
        state :ACTIVE
        state :REVOKED
        state :REFUSED
        state :EXPIRED

        # Transitions
        after_all_transitions :log_status_change

        event :activate do
          transitions from: :PENDING,
                      to: :ACTIVE,
                      after: :set_expiry_date
        end

        event :revoke do
          transitions from: :ACTIVE,
                      to: :REVOKED
        end

        event :refuse do
          transitions from: :PENDING,
                      to: :REFUSED
        end

        event :expire do
          transitions from: :ACTIVE,
                      to: :EXPIRED
        end

        event :renew do
          transitions from: %i[ACTIVE
                               EXPIRED],
                      to: :ACTIVE,
                      guard: %i[renewal_allowed?],
                      after: %i[extend_expiry_date
                                update_activation_timestamps]
        end
      end

      # Transition effects
      def set_expiry_date
        registration.expires_on = Rails.configuration.expires_after.years.from_now
      end

      def extend_expiry_date
        new_expiry_date = expiry_date_after_renewal(registration.expires_on)
        registration.expires_on = new_expiry_date
      end

      def update_activation_timestamps
        self.date_registered = Time.now
        self.date_activated = date_registered
      end

      def log_status_change
        logger.debug "Changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event})"
      end
    end

    private

    # Guards
    def renewal_allowed?
      return true if renewal_declaration_confirmed?

      # The only time an expired registration can be renewed is if the
      # application
      # - has a confirmed declaration i.e. user reached the copy cards page
      # - it is withion the grace window
      check_service = ExpiryCheckService.new(registration)
      return true if check_service.in_expiry_grace_window?
      return false if check_service.expired?

      check_service.in_renewal_window?
    end

    def renewal_application_submitted?
      transient_registration = matching_transient_registration
      return false unless transient_registration.present?

      transient_registration.workflow_state == "renewal_received_form"
    end

    def renewal_declaration_confirmed?
      transient_registration = matching_transient_registration
      return false unless transient_registration.present?

      transient_registration.declaration_confirmed?
    end

    def matching_transient_registration
      TransientRegistration.where(reg_identifier: registration.reg_identifier).first
    end
  end
  # rubocop:enable Metrics/BlockLength
end
