# frozen_string_literal: true

module WasteCarriersEngine
  module CanUseCeasedOrRevokedRegistrationWorkflow
    extend ActiveSupport::Concern
    include Mongoid::Document

    # rubocop:disable Metrics/BlockLength
    included do
      include AASM

      field :workflow_state, type: String

      aasm column: :workflow_state do
        # States / forms
        state :cease_or_revoke_form, initial: true

        state :ceased_or_revoked_confirm_form
        state :ceased_or_revoked_completed_form

        # Transitions
        event :next do
          transitions from: :cease_or_revoke_form,
                      to: :ceased_or_revoked_confirm_form

          transitions from: :ceased_or_revoked_confirm_form,
                      to: :ceased_or_revoked_completed_form

        end

        event :back do
          transitions from: :ceased_or_revoked_confirm_form,
                      to: :cease_or_revoke_form
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
