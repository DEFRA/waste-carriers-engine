# frozen_string_literal: true

module WasteCarriersEngine
  module CanUseEditRegistrationWorkflow
    extend ActiveSupport::Concern
    include Mongoid::Document

    # rubocop:disable Metrics/BlockLength
    included do
      include AASM

      field :workflow_state, type: String

      aasm column: :workflow_state do
        # States / forms
        state :edit_form, initial: true

        # Registration and account
        state :cbd_type_form

        # Business details
        state :company_name_form
        state :main_people_form
        state :company_postcode_form
        state :company_address_form
        state :company_address_manual_form

        # Contact details
        state :contact_name_form
        state :contact_phone_form
        state :contact_email_form
        state :contact_postcode_form
        state :contact_address_form
        state :contact_address_manual_form

        # Location
        state :location_form

        # Complete an edit
        state :declaration_form
        state :edit_complete_form

        # Transitions
        event :next do
          transitions from: :cbd_type_form,
                      to: :edit_form

          transitions from: :company_name_form,
                      to: :edit_form

          transitions from: :contact_name_form,
                      to: :edit_form

          transitions from: :contact_phone_form,
                      to: :edit_form

          transitions from: :contact_email_form,
                      to: :edit_form

          transitions from: :location_form,
                      to: :edit_form

          transitions from: :edit_form,
                      to: :declaration_form

          transitions from: :declaration_form,
                      to: :edit_complete_form
        end

        event :back do
          transitions from: :cbd_type_form,
                      to: :edit_form

          transitions from: :company_name_form,
                      to: :edit_form

          transitions from: :contact_name_form,
                      to: :edit_form

          transitions from: :contact_phone_form,
                      to: :edit_form

          transitions from: :contact_email_form,
                      to: :edit_form

          transitions from: :location_form,
                      to: :edit_form

          transitions from: :declaration_form,
                      to: :edit_form
        end
      end
      # rubocop:enable Metrics/BlockLength
    end
  end
end
