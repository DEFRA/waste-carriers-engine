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

        event :sign_off do
          transitions from: %i[possible_match
                               checks_in_progress],
                      to: :approved
        end

        event :reject do
          transitions from: %i[possible_match
                               checks_in_progress],
                      to: :rejected
        end
      end
    end
  end
end
