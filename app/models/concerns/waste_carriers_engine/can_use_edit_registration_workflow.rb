# frozen_string_literal: true

module WasteCarriersEngine
  module CanUseEditRegistrationWorkflow
    extend ActiveSupport::Concern
    include Mongoid::Document

    included do
      include AASM

      field :workflow_state, type: String

      aasm column: :workflow_state do
        # States / forms
        state :edit_form, initial: true

        state :declaration_form
        state :edit_complete_form

        # Transitions
        event :next do
          transitions from: :edit_form,
                      to: :declaration_form

          transitions from: :declaration_form,
                      to: :edit_complete_form
        end

        event :back do
          transitions from: :declaration_form,
                      to: :edit_form
        end
      end
    end
  end
end
