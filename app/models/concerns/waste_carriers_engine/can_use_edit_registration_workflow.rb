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
          # Registration and account
          transitions from: :cbd_type_form,
                      to: :edit_form

          # Business details
          transitions from: :company_name_form,
                      to: :edit_form

          transitions from: :main_people_form,
                      to: :edit_form

          # Company address
          transitions from: :company_postcode_form,
                      to: :company_address_manual_form,
                      if: :skip_to_manual_address?

          transitions from: :company_postcode_form,
                      to: :company_address_form

          transitions from: :company_address_form,
                      to: :company_address_manual_form,
                      if: :skip_to_manual_address?

          transitions from: :company_address_form,
                      to: :edit_form

          transitions from: :company_address_manual_form,
                      to: :edit_form

          # Contact details
          transitions from: :contact_name_form,
                      to: :edit_form

          transitions from: :contact_phone_form,
                      to: :edit_form

          transitions from: :contact_email_form,
                      to: :edit_form

          # Contact address
          transitions from: :contact_postcode_form,
                      to: :contact_address_manual_form,
                      if: :skip_to_manual_address?

          transitions from: :contact_postcode_form,
                      to: :contact_address_form

          transitions from: :contact_address_form,
                      to: :contact_address_manual_form,
                      if: :skip_to_manual_address?

          transitions from: :contact_address_form,
                      to: :edit_form

          transitions from: :contact_address_manual_form,
                      to: :edit_form

          # Location
          transitions from: :location_form,
                      to: :edit_form

          # Complete an edit
          transitions from: :edit_form,
                      to: :declaration_form

          transitions from: :declaration_form,
                      to: :edit_complete_form
        end

        event :back do
          # Registration and account
          transitions from: :cbd_type_form,
                      to: :edit_form

          # Business details
          transitions from: :company_name_form,
                      to: :edit_form

          transitions from: :main_people_form,
                      to: :edit_form

          # Company address
          transitions from: :company_postcode_form,
                      to: :edit_form

          transitions from: :company_address_form,
                      to: :company_postcode_form

          transitions from: :company_address_manual_form,
                      to: :edit_form,
                      if: :based_overseas?

          transitions from: :company_address_manual_form,
                      to: :company_postcode_form

          # Contact details
          transitions from: :contact_name_form,
                      to: :edit_form

          transitions from: :contact_phone_form,
                      to: :edit_form

          transitions from: :contact_email_form,
                      to: :edit_form

          # Contact address
          transitions from: :contact_postcode_form,
                      to: :edit_form

          transitions from: :contact_address_form,
                      to: :contact_postcode_form

          transitions from: :contact_address_manual_form,
                      to: :edit_form,
                      if: :based_overseas?

          transitions from: :contact_address_manual_form,
                      to: :contact_postcode_form

          # Location
          transitions from: :location_form,
                      to: :edit_form

          # Complete an edit
          transitions from: :declaration_form,
                      to: :edit_form
        end

        event :skip_to_manual_address do
          transitions from: :company_postcode_form,
                      to: :company_address_manual_form

          transitions from: :company_address_form,
                      to: :company_address_manual_form

          transitions from: :contact_postcode_form,
                      to: :contact_address_manual_form

          transitions from: :contact_address_form,
                      to: :contact_address_manual_form
        end
      end
      # rubocop:enable Metrics/BlockLength
    end

    private

    def based_overseas?
      overseas?
    end

    def registered_address_was_manually_entered?
      return unless registered_address

      registered_address.manually_entered?
    end

    def skip_to_manual_address?
      temp_os_places_error
    end

    def contact_address_was_manually_entered?
      return unless contact_address

      contact_address.manually_entered?
    end
  end
end
