# frozen_string_literal: true

module WasteCarriersEngine
  # rubocop:disable Metrics/ModuleLength
  module CanUseNewRegistrationWorkflow
    extend ActiveSupport::Concern
    include Mongoid::Document

    # rubocop:disable Metrics/BlockLength
    included do
      include AASM

      field :workflow_state, type: String

      aasm column: :workflow_state do
        # States / forms

        # Start
        state :start_form, initial: true

        # Renew
        state :renew_registration_form
        state :renewal_stop_form

        # Location
        state :location_form
        state :register_in_northern_ireland_form
        state :register_in_scotland_form
        state :register_in_wales_form

        state :business_type_form

        state :other_businesses_form
        state :service_provided_form
        state :construction_demolition_form
        state :waste_types_form

        state :check_your_tier_form
        state :your_tier_form

        state :cbd_type_form
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
        state :contact_address_manual_form
        state :contact_address_reuse_form

        state :check_your_answers_form
        state :declaration_form
        state :cards_form
        state :payment_summary_form
        state :payment_method_confirmation_form
        state :govpay_form
        state :confirm_bank_transfer_form

        state :registration_completed_form
        state :registration_received_pending_payment_form
        state :registration_received_pending_conviction_form
        state :registration_received_pending_govpay_payment_form

        # Transitions
        event :next do
          # Start
          transitions from: :start_form, to: :location_form,
                      unless: :should_renew?

          transitions from: :start_form, to: :renewal_stop_form

          # Location
          transitions from: :location_form, to: :register_in_northern_ireland_form,
                      if: :should_register_in_northern_ireland?

          transitions from: :location_form, to: :register_in_scotland_form,
                      if: :should_register_in_scotland?

          transitions from: :location_form, to: :register_in_wales_form,
                      if: :should_register_in_wales?

          transitions from: :location_form, to: :check_your_tier_form,
                      if: :overseas?

          transitions from: :location_form, to: :business_type_form

          transitions from: :register_in_northern_ireland_form, to: :business_type_form

          transitions from: :register_in_scotland_form, to: :business_type_form

          transitions from: :register_in_wales_form, to: :business_type_form

          # Business type
          transitions from: :business_type_form, to: :your_tier_form,
                      if: :switch_to_lower_tier_based_on_business_type?,
                      after: :switch_to_lower_tier

          transitions from: :business_type_form, to: :check_your_tier_form

          # Tier
          transitions from: :check_your_tier_form, to: :other_businesses_form,
                      if: :check_your_tier_unknown?

          transitions from: :check_your_tier_form, to: :cbd_type_form,
                      if: :check_your_tier_upper?,
                      after: :set_tier_from_check_your_tier_form

          transitions from: :check_your_tier_form, to: :company_name_form,
                      if: :set_tier_and_company_name_required?, after: :set_tier_from_check_your_tier_form

          transitions from: :check_your_tier_form, to: :use_trading_name_form,
                      if: :upper_tier?, after: :set_tier_from_check_your_tier_form

          # Smart answers
          transitions from: :other_businesses_form, to: :construction_demolition_form,
                      if: :only_carries_own_waste?

          transitions from: :other_businesses_form, to: :service_provided_form

          transitions from: :service_provided_form, to: :waste_types_form,
                      if: :waste_is_main_service?

          transitions from: :service_provided_form, to: :construction_demolition_form

          transitions from: :waste_types_form, to: :your_tier_form,
                      if: :switch_to_lower_tier_based_on_smart_answers?,
                      after: :switch_to_lower_tier

          transitions from: :waste_types_form, to: :your_tier_form,
                      after: :switch_to_upper_tier

          transitions from: :your_tier_form, to: :company_name_form,
                      if: :lower_tier?

          transitions from: :your_tier_form, to: :cbd_type_form

          transitions from: :construction_demolition_form, to: :your_tier_form,
                      if: :switch_to_lower_tier_based_on_smart_answers?,
                      after: :switch_to_lower_tier

          transitions from: :construction_demolition_form, to: :your_tier_form,
                      after: :switch_to_upper_tier

          # CBD Type
          transitions from: :cbd_type_form, to: :main_people_form,
                      if: :skip_registration_number?

          transitions from: :cbd_type_form, to: :registration_number_form

          # Registered company details
          transitions from: :registration_number_form, to: :check_registered_company_name_form

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
          transitions from: :main_people_form, to: :company_name_form, if: :company_name_required?

          transitions from: :main_people_form, to: :use_trading_name_form

          # Convictions
          transitions from: :declare_convictions_form, to: :conviction_details_form,
                      if: :declared_convictions?

          transitions from: :declare_convictions_form, to: :contact_name_form

          transitions from: :conviction_details_form, to: :contact_name_form

          # Contact details
          transitions from: :contact_name_form, to: :contact_phone_form

          transitions from: :contact_phone_form, to: :contact_email_form

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

          transitions from: :declaration_form, to: :registration_completed_form,
                      if: :lower_tier?

          transitions from: :declaration_form, to: :cards_form

          # Payment & Completion
          transitions from: :cards_form, to: :payment_summary_form

          transitions from: :payment_summary_form, to: :payment_method_confirmation_form

          transitions from: :payment_method_confirmation_form, to: :payment_summary_form,
                      if: :payment_method_not_confirmed?

          transitions from: :payment_method_confirmation_form, to: :govpay_form,
                      if: :paying_by_card?

          transitions from: :payment_method_confirmation_form, to: :confirm_bank_transfer_form

          transitions from: :confirm_bank_transfer_form, to: :registration_received_pending_payment_form

          transitions from: :govpay_form,
                      to: :registration_received_pending_govpay_payment_form,
                      if: :pending_online_payment?

          transitions from: :govpay_form,
                      to: :registration_received_pending_conviction_form,
                      if: :conviction_check_required?

          transitions from: :govpay_form, to: :registration_completed_form
        end

        # Transitions

        event :skip_to_manual_address do
          transitions from: :company_postcode_form, to: :company_address_manual_form

          transitions from: :company_address_form, to: :company_address_manual_form

          transitions from: :contact_postcode_form, to: :contact_address_manual_form

          transitions from: :contact_address_form, to: :contact_address_manual_form
        end
      end

      private

      def should_renew?
        temp_start_option == WasteCarriersEngine::StartForm::RENEW
      end

      def skip_registration_number?
        !company_no_required?
      end

      # Charity registrations should be lower tier
      def switch_to_lower_tier_based_on_business_type?
        charity?
      end

      def switch_to_lower_tier_based_on_smart_answers?
        SmartAnswersCheckerService.new(self).lower_tier?
      end

      def only_carries_own_waste?
        # TODO: Make this a boolean
        other_businesses == "no"
      end

      def waste_is_main_service?
        # TODO: Make this a boolean
        is_main_service == "yes"
      end

      def registered_address_was_manually_entered?
        return false unless registered_address

        registered_address.manually_entered?
      end

      def skip_to_manual_address?
        temp_os_places_error
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

      def switch_to_lower_tier
        update_attributes(tier: WasteCarriersEngine::NewRegistration::LOWER_TIER)
      end

      def not_only_amf?
        only_amf == "no"
      end

      def switch_to_upper_tier
        update_attributes(tier: WasteCarriersEngine::NewRegistration::UPPER_TIER)
      end

      def check_your_tier_unknown?
        temp_check_your_tier == "unknown"
      end

      def check_your_tier_lower?
        temp_check_your_tier == "lower"
      end

      def check_your_tier_upper?
        temp_check_your_tier == "upper"
      end

      def set_tier_from_check_your_tier_form
        return switch_to_upper_tier if temp_check_your_tier == "upper"

        switch_to_lower_tier
      end

      def set_tier_and_company_name_required?
        set_tier_from_check_your_tier_form
        company_name_required?
      end

      def reuse_registered_address?
        temp_reuse_registered_address == "yes"
      end

      def set_contact_address_as_registered_address
        WasteCarriersEngine::ContactAddressAsRegisteredAddressService.run(self)
      end

      def incorrect_company_data?
        temp_use_registered_company_details == "no"
      end

      def use_trading_name?
        temp_use_trading_name == "yes"
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
  # rubocop:enable Metrics/ModuleLength
end
