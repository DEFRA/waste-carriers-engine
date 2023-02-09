# frozen_string_literal: true

module WasteCarriersEngine
  module CanUseDeregistrationWorkflow
    extend ActiveSupport::Concern
    include Mongoid::Document

    included do
      include AASM

      field :workflow_state, type: String

      aasm column: :workflow_state do
        state :deregistration_confirmation_form, initial: true
        state :deregistration_complete_form
        state :start_form

        event :next do
          transitions from: :deregistration_confirmation_form, to: :deregistration_complete_form,
                      if: :confirm_deregistration?

          # default to the start page
          transitions from: :deregistration_confirmation_form, to: :start_form
        end
      end

      private

      def confirm_deregistration?
        temp_confirm_deregistration == "yes"
      end
    end
  end
end
