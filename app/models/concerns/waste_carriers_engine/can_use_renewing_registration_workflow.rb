# frozen_string_literal: true

require "defra_ruby_companies_house"

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
        state :start_form

        state :location_form
        state :register_in_northern_ireland_form
        state :register_in_scotland_form
        state :register_in_wales_form

        state :business_type_form

        state :cbd_type_form
        state :renewal_information_form
        state :invalid_company_status_form
        state :registration_number_form
        state :check_registered_company_name_form
        state :incorrect_company_form

        state :use_trading_name_form
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
        state :contact_address_reuse_form
        state :contact_address_manual_form

        state :check_your_answers_form
        state :declaration_form
        state :cards_form
        state :payment_summary_form
        state :payment_method_confirmation_form
        state :govpay_form
        state :confirm_bank_transfer_form

        state :renewal_complete_form
        state :renewal_received_pending_conviction_form
        state :renewal_received_pending_payment_form
        state :renewal_received_pending_govpay_payment_form

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
                      if: :overseas?

          transitions from: :location_form, to: :business_type_form

          transitions from: :register_in_northern_ireland_form, to: :business_type_form

          transitions from: :register_in_scotland_form, to: :business_type_form

          transitions from: :register_in_wales_form, to: :business_type_form

          # Business type
          transitions from: :business_type_form, to: :cbd_type_form,
                      if: :business_type_change_valid?

          transitions from: :business_type_form, to: :cannot_renew_type_change_form

          # CBD type
          transitions from: :cbd_type_form, to: :renewal_information_form

          # Renewal information
          transitions from: :renewal_information_form, to: :invalid_company_status_form,
                      if: :company_status_invalid?

          transitions from: :renewal_information_form, to: :check_registered_company_name_form,
                      unless: :skip_registration_number?

          transitions from: :renewal_information_form, to: :main_people_form,
                      if: :upper_tier?

          transitions from: :renewal_information_form, to: :company_name_form,
                      if: :company_name_required?

          transitions from: :renewal_information_form, to: :use_trading_name_form

          # Registered company details
          transitions from: :invalid_company_status_form, to: :start_form

          transitions from: :check_registered_company_name_form, to: :incorrect_company_form,
                      if: :incorrect_company_data?

          transitions from: :check_registered_company_name_form, to: :main_people_form

          transitions from: :incorrect_company_form, to: :registration_number_form

          # Trading name
          transitions from: :use_trading_name_form, to: :company_name_form,
                      if: :use_trading_name?

          transitions from: :use_trading_name_form, to: :company_address_manual_form,
                      if: :overseas?

          transitions from: :use_trading_name_form, to: :company_postcode_form

          transitions from: :company_name_form, to: :company_address_manual_form,
                      if: :overseas?

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

          # Main people
          transitions from: :main_people_form, to: :company_name_form,
                      if: :company_name_required?

          transitions from: :main_people_form, to: :use_trading_name_form

          # Convictions
          transitions from: :declare_convictions_form, to: :conviction_details_form,
                      if: :declared_convictions?

          transitions from: :declare_convictions_form, to: :contact_name_form

          transitions from: :conviction_details_form, to: :contact_name_form

          transitions from: :contact_name_form, to: :contact_phone_form

          transitions from: :contact_phone_form, to: :contact_email_form

          transitions from: :contact_email_form, to: :contact_address_manual_form,
                      if: :overseas?

          transitions from: :contact_email_form, to: :contact_address_reuse_form

          # Contact address
          transitions from: :contact_address_reuse_form, to: :check_your_answers_form,
                      if: :reuse_registered_address?,
                      after: :set_contact_address_as_registered_address

          transitions from: :contact_address_reuse_form, to: :contact_address_manual_form,
                      unless: :reuse_registered_address?,
                      if: :overseas?

          transitions from: :contact_address_reuse_form, to: :contact_postcode_form,
                      unless: :reuse_registered_address?

          transitions from: :contact_postcode_form, to: :contact_address_manual_form,
                      if: :skip_to_manual_address?

          transitions from: :contact_postcode_form, to: :contact_address_form

          transitions from: :contact_address_form, to: :contact_address_manual_form,
                      if: :skip_to_manual_address?

          transitions from: :contact_address_form, to: :check_your_answers_form

          transitions from: :contact_address_manual_form, to: :check_your_answers_form

          # Check answers & declaration

          transitions from: :check_your_answers_form, to: :declaration_form

          transitions from: :declaration_form, to: :cards_form

          # Payment & completion
          transitions from: :cards_form, to: :payment_summary_form

          transitions from: :payment_summary_form, to: :payment_method_confirmation_form

          transitions from: :payment_method_confirmation_form, to: :payment_summary_form,
                      if: :payment_method_not_confirmed?

          transitions from: :payment_method_confirmation_form, to: :govpay_form,
                      if: :paying_by_card?

          transitions from: :payment_method_confirmation_form, to: :confirm_bank_transfer_form

          transitions from: :govpay_form, to: :renewal_received_pending_govpay_payment_form,
                      if: :pending_online_payment?,
                      success: :send_renewal_pending_online_payment_email

          transitions from: :govpay_form, to: :renewal_received_pending_conviction_form,
                      if: :conviction_check_required?,
                      success: :send_renewal_pending_checks_email

          transitions from: :govpay_form, to: :renewal_complete_form

          transitions from: :confirm_bank_transfer_form, to: :renewal_received_pending_payment_form,
                      success: :send_renewal_pending_payment_email
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

    def company_status_invalid?
      return false if company_no.blank? || overseas?

      begin
        company_status = DefraRubyCompaniesHouse.new(company_no).company_status
        !%w[active voluntary-arrangement].include?(company_status)
      rescue StandardError
        true
      end
    end

    def skip_registration_number?
      !company_no_required?
    end

    def skip_to_manual_address?
      temp_os_places_error
    end

    def contact_address_was_manually_entered?
      return false unless contact_address

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

    def payment_method_not_confirmed?
      temp_confirm_payment_method == "no"
    end

    def use_trading_name?
      temp_use_trading_name == "yes"
    end

    def incorrect_company_data?
      temp_use_registered_company_details == "no"
    end

    def reuse_registered_address?
      temp_reuse_registered_address == "yes"
    end

    def set_contact_address_as_registered_address
      WasteCarriersEngine::ContactAddressAsRegisteredAddressService.run(self)
    end

    def send_renewal_pending_online_payment_email
      WasteCarriersEngine::Notify::RenewalPendingOnlinePaymentEmailService.run(registration: self)
    rescue StandardError => e
      Airbrake.notify(e, registration_no: reg_identifier) if defined?(Airbrake)
    end

    def send_renewal_pending_checks_email
      WasteCarriersEngine::Notify::RenewalPendingChecksEmailService.run(registration: self)
    rescue StandardError => e
      Airbrake.notify(e, registration_no: reg_identifier) if defined?(Airbrake)
    end

    def send_renewal_pending_payment_email
      WasteCarriersEngine::Notify::RenewalPendingPaymentEmailService.run(registration: self)
    rescue StandardError => e
      Airbrake.notify(e, registration_no: reg_identifier) if defined?(Airbrake)
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
