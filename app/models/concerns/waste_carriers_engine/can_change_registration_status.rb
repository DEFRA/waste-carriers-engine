# frozen_string_literal: true

module WasteCarriersEngine
  module CanChangeRegistrationStatus
    extend ActiveSupport::Concern
    include Mongoid::Document

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
        state :INACTIVE

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
                      to: :ACTIVE
        end
      end

      # Transition effects
      def set_expiry_date
        registration.expires_on = Rails.configuration.expires_after.years.from_now
      end

      def log_status_change
        logger.debug "Changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event})"
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
