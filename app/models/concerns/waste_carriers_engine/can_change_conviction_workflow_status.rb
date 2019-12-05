# frozen_string_literal: true

module WasteCarriersEngine
  module CanChangeConvictionWorkflowStatus
    extend ActiveSupport::Concern
    include Mongoid::Document

    included do
      include AASM

      field :workflow_state, type: String

      aasm column: :workflow_state do
        state :possible_match, initial: true
        state :checks_in_progress
        state :approved
        state :rejected

        event :begin_checks do
          transitions from: :possible_match,
                      to: :checks_in_progress
        end

        event :approve do
          transitions from: %i[possible_match
                               checks_in_progress],
                      to: :approved,
                      after: :update_confirmed_info
        end

        event :reject do
          transitions from: :checks_in_progress,
                      to: :rejected,
                      after: %i[refuse_or_revoke_parent
                                update_confirmed_info]
        end
      end
    end

    private

    def update_confirmed_info(current_user)
      self.confirmed = "yes"
      self.confirmed_at = Time.current
      self.confirmed_by = current_user.email
    end

    def refuse_or_revoke_parent
      return unless _parent&.metaData

      if _parent.pending?
        _parent.metaData.refuse!
      else
        _parent.metaData.revoke!
      end
    end
  end
end
