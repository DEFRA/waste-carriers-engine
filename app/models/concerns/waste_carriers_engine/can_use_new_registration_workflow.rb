# frozen_string_literal: true

module WasteCarriersEngine
  module CanUseNewRegistrationWorkflow
    extend ActiveSupport::Concern
    include Mongoid::Document

    included do
      include AASM

      field :workflow_state, type: String

      aasm column: :workflow_state do
        # States / forms

        # Start
        state :start_form, initial: true

        # Location
        state :location_form

        # Renew
        state :renew_registration_form

        # Transitions
        event :next do
          # Start
          transitions from: :start_form,
                      to: :location_form,
                      unless: :should_renew?

          transitions from: :start_form,
                      to: :renew_registration_form,
                      if: :should_renew?
        end

        # Transitions
        event :back do
          transitions from: :location_form,
                      to: :start_form

          transitions from: :renew_registration_form,
                      to: :start_form
        end
      end

      private

      def should_renew?
        temp_start_option == WasteCarriersEngine::StartForm::RENEW
      end
    end
  end
end
