# frozen_string_literal: true

module WasteCarriersEngine
  # rubocop:disable Metrics/ModuleLength
  module CanUseRenewingRegistrationWorkflow
    extend ActiveSupport::Concern
    include Mongoid::Document

    # rubocop:disable Metrics/BlockLength
    included do
      include AASM

      field :workflow_state, type: String

      aasm column: :workflow_state do
        # States / forms
        state :renewal_start_form, initial: true

        state :location_form
        state :register_in_northern_ireland_form
        state :register_in_scotland_form
        state :register_in_wales_form

        state :business_type_form

        state :cbd_type_form
        state :renewal_information_form
        state :registration_number_form
        state :check_registered_company_name_form
        state :incorrect_company_form

        state :company_name_form
        state :company_postcode_form
        state :company_address_form
        state :company_address_manual_form

        state :main_people_form

        state :declare_convictions_form
        state :conviction_details_form

        state :contact_name_form
        state :contact_phone_form
        state :contact_email_form
        state :contact_postcode_form
        state :contact_address_form
        state :contact_address_manual_form

        state :check_your_answers_form
        state :declaration_form
        state :cards_form
        state :payment_summary_form
        state :worldpay_form
        state :confirm_bank_transfer_form

        state :renewal_complete_form
        state :renewal_received_pending_conviction_form
        state :renewal_received_pending_payment_form
        state :renewal_received_pending_worldpay_payment_form

        state :cannot_renew_type_change_form

        # Transitions
        event :next do
          transitions from: :renewal_start_form, to: :location_form

          # Location

          transitions from: :location_form, to: :register_in_northern_ireland_form,
                      if: :should_register_in_northern_ireland?

          transitions from: :location_form, to: :register_in_scotland_form,
                      if: :should_register_in_scotland?

          transitions from: :location_form, to: :register_in_wales_form,
                      if: :should_register_in_wales?

          transitions from: :location_form, to: :cbd_type_form,
                      if: :based_overseas?

          transitions from: :location_form, to: :business_type_form

          transitions from: :register_in_northern_ireland_form, to: :business_type_form

          transitions from: :register_in_scotland_form, to: :business_type_form

          transitions from: :register_in_wales_form, to: :business_type_form

          # End location

          transitions from: :business_type_form, to: :cbd_type_form,
                      if: :business_type_change_valid?

          transitions from: :business_type_form, to: :cannot_renew_type_change_form

          transitions from: :cbd_type_form, to: :renewal_information_form

          transitions from: :renewal_information_form, to: :check_registered_company_name_form,
                      unless: :skip_registration_number?

          transitions from: :renewal_information_form, to: :main_people_form,
                      if: :upper_tier?

          transitions from: :renewal_information_form, to: :company_name_form

          transitions from: :check_registered_company_name_form, to: :incorrect_company_form,
                      if: :incorrect_company_data?

          transitions from: :check_registered_company_name_form, to: :main_people_form

          transitions from: :incorrect_company_form, to: :registration_number_form

          transitions from: :company_name_form, to: :company_address_manual_form,
                      if: :based_overseas?

          transitions from: :company_name_form, to: :company_postcode_form

          # Registered address

          transitions from: :company_postcode_form, to: :company_address_manual_form,
                      if: :skip_to_manual_address?

          transitions from: :company_postcode_form, to: :company_address_form

          transitions from: :company_address_form, to: :company_address_manual_form,
                      if: :skip_to_manual_address?

          transitions from: :company_address_form, to: :contact_name_form,
                      if: :lower_tier?

          transitions from: :company_address_form, to: :declare_convictions_form

          transitions from: :company_address_manual_form, to: :contact_name_form,
                      if: :lower_tier?

          transitions from: :company_address_manual_form, to: :declare_convictions_form

          # End registered address

          transitions from: :main_people_form, to: :company_name_form

          transitions from: :declare_convictions_form, to: :conviction_details_form,
                      if: :declared_convictions?

          transitions from: :declare_convictions_form, to: :contact_name_form

          transitions from: :conviction_details_form, to: :contact_name_form

          transitions from: :contact_name_form, to: :contact_phone_form

          transitions from: :contact_phone_form, to: :contact_email_form

          transitions from: :contact_email_form, to: :contact_address_manual_form,
                      if: :based_overseas?

          transitions from: :contact_email_form, to: :contact_postcode_form

          # Contact address

          transitions from: :contact_postcode_form, to: :contact_address_manual_form,
                      if: :skip_to_manual_address?

          transitions from: :contact_postcode_form, to: :contact_address_form

          transitions from: :contact_address_form, to: :contact_address_manual_form,
                      if: :skip_to_manual_address?

          transitions from: :contact_address_form, to: :check_your_answers_form

          transitions from: :contact_address_manual_form, to: :check_your_answers_form

          # End contact address

          transitions from: :check_your_answers_form, to: :declaration_form

          transitions from: :declaration_form, to: :cards_form

          transitions from: :cards_form, to: :payment_summary_form

          transitions from: :payment_summary_form, to: :worldpay_form,
                      if: :paying_by_card?

          transitions from: :payment_summary_form, to: :confirm_bank_transfer_form

          transitions from: :worldpay_form, to: :renewal_received_pending_worldpay_payment_form,
                      if: :pending_worldpay_payment?,
                      success: :send_renewal_pending_worldpay_payment_email,
                      # TODO: This don't get triggered if in the `success`
                      # callback block, hence we went for `after`
                      after: :set_metadata_route

          transitions from: :worldpay_form, to: :renewal_received_pending_conviction_form,
                      if: :conviction_check_required?,
                      success: :send_renewal_pending_checks_email,
                      # TODO: This don't get triggered if in the `success`
                      # callback block, hence we went for `after`
                      after: :set_metadata_route

          transitions from: :worldpay_form, to: :renewal_complete_form,
                      # TODO: This don't get triggered if in the `success`
                      # callback block, hence we went for `after`
                      after: :set_metadata_route

          transitions from: :confirm_bank_transfer_form, to: :renewal_received_pending_payment_form,
                      success: :send_renewal_received_pending_payment_email,
                      # TODO: This don't get triggered if in the `success`
                      # callback block, hence we went for `after`
                      after: :set_metadata_route
        end

        event :back do
          # Location

          transitions from: :location_form, to: :renewal_start_form

          transitions from: :register_in_northern_ireland_form, to: :location_form

          transitions from: :register_in_scotland_form, to: :location_form

          transitions from: :register_in_wales_form, to: :location_form

          # End location

          transitions from: :business_type_form, to: :register_in_northern_ireland_form,
                      if: :should_register_in_northern_ireland?

          transitions from: :business_type_form, to: :register_in_scotland_form,
                      if: :should_register_in_scotland?

          transitions from: :business_type_form, to: :register_in_wales_form,
                      if: :should_register_in_wales?

          transitions from: :business_type_form, to: :location_form

          # Smart answers

          transitions from: :cbd_type_form, to: :location_form,
                      if: :based_overseas?

          transitions from: :cbd_type_form, to: :business_type_form

          # End smart answers

          transitions from: :renewal_information_form, to: :cbd_type_form

          transitions from: :registration_number_form, to: :renewal_information_form

          transitions from: :company_name_form, to: :renewal_information_form,
                      if: :lower_tier?

          transitions from: :company_name_form, to: :main_people_form,
                      if: :skip_registration_number?

          transitions from: :company_name_form, to: :check_registered_company_name_form

          transitions from: :check_registered_company_name_form, to: :renewal_information_form

          transitions from: :incorrect_company_form, to: :check_registered_company_name_form

          # Registered address

          transitions from: :company_postcode_form, to: :company_name_form

          transitions from: :company_address_form, to: :company_postcode_form

          transitions from: :company_address_manual_form, to: :company_name_form,
                      if: :based_overseas?

          transitions from: :company_address_manual_form, to: :company_postcode_form

          transitions from: :main_people_form, to: :cbd_type_form

          # End registered address

          transitions from: :declare_convictions_form, to: :company_address_manual_form,
                      if: :registered_address_was_manually_entered?

          transitions from: :declare_convictions_form, to: :company_address_form

          transitions from: :conviction_details_form, to: :declare_convictions_form

          transitions from: :contact_name_form, to: :conviction_details_form,
                      if: :declared_convictions?

          transitions from: :contact_name_form, to: :declare_convictions_form

          transitions from: :contact_phone_form, to: :contact_name_form

          transitions from: :contact_email_form, to: :contact_phone_form

          # Contact address

          transitions from: :contact_postcode_form, to: :contact_email_form

          transitions from: :contact_address_form, to: :contact_postcode_form

          transitions from: :contact_address_manual_form, to: :contact_email_form,
                      if: :based_overseas?

          transitions from: :contact_address_manual_form, to: :contact_postcode_form

          transitions from: :check_your_answers_form, to: :contact_address_manual_form,
                      if: :contact_address_was_manually_entered?

          transitions from: :check_your_answers_form, to: :contact_address_form

          # End contact address

          transitions from: :declaration_form, to: :check_your_answers_form

          transitions from: :cards_form, to: :declaration_form

          transitions from: :payment_summary_form, to: :cards_form

          transitions from: :worldpay_form, to: :payment_summary_form

          transitions from: :confirm_bank_transfer_form, to: :payment_summary_form

          # Exit routes from renewals process

          transitions from: :cannot_renew_type_change_form, to: :business_type_form
        end

        event :skip_to_manual_address do
          transitions from: :company_postcode_form, to: :company_address_manual_form

          transitions from: :company_address_form, to: :company_address_manual_form

          transitions from: :contact_postcode_form, to: :contact_address_manual_form

          transitions from: :contact_address_form, to: :contact_address_manual_form
        end
      end
    end
    # rubocop:enable Metrics/BlockLength

    private

    def skip_registration_number?
      !company_no_required?
    end

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

    def should_register_in_northern_ireland?
      location == "northern_ireland"
    end

    def should_register_in_scotland?
      location == "scotland"
    end

    def should_register_in_wales?
      location == "wales"
    end

    def paying_by_card?
      temp_payment_method == "card"
    end

    def incorrect_company_data?
      temp_use_registered_company_details == "no"
    end

    def send_renewal_pending_worldpay_payment_email
      WasteCarriersEngine::Notify::RenewalPendingWorldpayPaymentEmailService.run(registration: self)
    rescue StandardError => e
      Airbrake.notify(e, registration_no: reg_identifier) if defined?(Airbrake)
    end

    def send_renewal_pending_checks_email
      WasteCarriersEngine::Notify::RenewalPendingChecksEmailService.run(registration: self)
    rescue StandardError => e
      Airbrake.notify(e, registration_no: reg_identifier) if defined?(Airbrake)
    end

    def send_renewal_received_pending_payment_email
      WasteCarriersEngine::Notify::RenewalPendingPaymentEmailService.run(registration: self)
    rescue StandardError => e
      Airbrake.notify(e, registration_no: reg_identifier) if defined?(Airbrake)
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
