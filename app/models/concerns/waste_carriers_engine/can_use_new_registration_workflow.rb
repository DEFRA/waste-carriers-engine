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

        state :cbd_type_form
        state :registration_number_form

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
        state :bank_transfer_form

        state :registration_completed_form
        state :registration_received_pending_payment_form
        state :registration_received_pending_conviction_form

        # Transitions
        event :next do
          # Start
          transitions from: :start_form,
                      to: :location_form,
                      unless: :should_renew?

          transitions from: :start_form,
                      to: :renew_registration_form,
                      if: :should_renew?

          # Location

          transitions from: :location_form,
                      to: :register_in_northern_ireland_form,
                      if: :should_register_in_northern_ireland?

          transitions from: :location_form,
                      to: :register_in_scotland_form,
                      if: :should_register_in_scotland?

          transitions from: :location_form,
                      to: :register_in_wales_form,
                      if: :should_register_in_wales?

          transitions from: :location_form,
                      to: :other_businesses_form,
                      if: :overseas?

          transitions from: :location_form,
                      to: :business_type_form

          transitions from: :register_in_northern_ireland_form,
                      to: :business_type_form

          transitions from: :register_in_scotland_form,
                      to: :business_type_form

          transitions from: :register_in_wales_form,
                      to: :business_type_form

          # End location

          transitions from: :business_type_form,
                      to: :company_name_form,
                      if: :switch_to_lower_tier_based_on_business_type?,
                      after: :switch_to_lower_tier

          transitions from: :business_type_form,
                      to: :other_businesses_form

          # Smart answers

          transitions from: :other_businesses_form,
                      to: :construction_demolition_form,
                      if: :only_carries_own_waste?

          transitions from: :other_businesses_form,
                      to: :service_provided_form

          transitions from: :service_provided_form,
                      to: :waste_types_form,
                      if: :waste_is_main_service?

          transitions from: :service_provided_form,
                      to: :construction_demolition_form

          transitions from: :waste_types_form,
                      to: :company_name_form,
                      if: :switch_to_lower_tier_based_on_smart_answers?,
                      after: :switch_to_lower_tier

          transitions from: :waste_types_form,
                      to: :cbd_type_form,
                      after: :switch_to_upper_tier

          transitions from: :construction_demolition_form,
                      to: :company_name_form,
                      if: :switch_to_lower_tier_based_on_smart_answers?,
                      after: :switch_to_lower_tier

          transitions from: :construction_demolition_form,
                      to: :cbd_type_form,
                      after: :switch_to_upper_tier

          # End smart answers

          transitions from: :cbd_type_form,
                      to: :company_name_form,
                      if: :skip_registration_number?

          transitions from: :cbd_type_form,
                      to: :registration_number_form

          transitions from: :registration_number_form,
                      to: :company_name_form

          transitions from: :company_name_form,
                      to: :company_address_manual_form,
                      if: :overseas?

          transitions from: :company_name_form,
                      to: :company_postcode_form

          # Registered address

          transitions from: :company_postcode_form,
                      to: :company_address_manual_form,
                      if: :skip_to_manual_address?

          transitions from: :company_postcode_form,
                      to: :company_address_form

          transitions from: :company_address_form,
                      to: :company_address_manual_form,
                      if: :skip_to_manual_address?

          transitions from: :company_address_form,
                      to: :contact_name_form,
                      if: :lower_tier?

          transitions from: :company_address_form,
                      to: :main_people_form

          transitions from: :company_address_manual_form,
                      to: :contact_name_form,
                      if: :lower_tier?

          transitions from: :company_address_manual_form,
                      to: :main_people_form

          # End registered address

          transitions from: :main_people_form,
                      to: :declare_convictions_form

          transitions from: :declare_convictions_form,
                      to: :conviction_details_form,
                      if: :declared_convictions?

          transitions from: :declare_convictions_form,
                      to: :contact_name_form

          transitions from: :conviction_details_form,
                      to: :contact_name_form

          transitions from: :contact_name_form,
                      to: :contact_phone_form

          transitions from: :contact_phone_form,
                      to: :contact_email_form

          transitions from: :contact_email_form,
                      to: :contact_address_manual_form,
                      if: :overseas?

          transitions from: :contact_email_form,
                      to: :contact_postcode_form

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
                      to: :check_your_answers_form

          transitions from: :contact_address_manual_form,
                      to: :check_your_answers_form

          # End contact address

          transitions from: :check_your_answers_form,
                      to: :declaration_form

          transitions from: :declaration_form,
                      to: :registration_completed_form,
                      if: :lower_tier?

          transitions from: :declaration_form,
                      to: :cards_form

          transitions from: :cards_form,
                      to: :payment_summary_form

          transitions from: :payment_summary_form,
                      to: :worldpay_form,
                      if: :paying_by_card?

          transitions from: :payment_summary_form,
                      to: :bank_transfer_form

          # Registration completion forms
          transitions from: :bank_transfer_form,
                      to: :registration_received_pending_payment_form,
                      # TODO: This don't get triggered if in the `success`
                      # callback block, hence we went for `after`
                      after: :set_metadata_route

          transitions from: :worldpay_form,
                      to: :registration_received_pending_conviction_form,
                      if: :conviction_check_required?,
                      # TODO: This don't get triggered if in the `success`
                      # callback block, hence we went for `after`
                      after: :set_metadata_route
        end

        # Transitions
        event :back do
          transitions from: :location_form,
                      to: :start_form

          transitions from: :renew_registration_form,
                      to: :start_form

          # Location

          transitions from: :location_form,
                      to: :renewal_start_form

          transitions from: :register_in_northern_ireland_form,
                      to: :location_form

          transitions from: :register_in_scotland_form,
                      to: :location_form

          transitions from: :register_in_wales_form,
                      to: :location_form

          # End location

          transitions from: :business_type_form,
                      to: :register_in_northern_ireland_form,
                      if: :should_register_in_northern_ireland?

          transitions from: :business_type_form,
                      to: :register_in_scotland_form,
                      if: :should_register_in_scotland?

          transitions from: :business_type_form,
                      to: :register_in_wales_form,
                      if: :should_register_in_wales?

          transitions from: :business_type_form,
                      to: :location_form

          # Smart answers
          transitions from: :company_name_form,
                      to: :business_type_form,
                      if: :switch_to_lower_tier_based_on_business_type?

          transitions from: :company_name_form,
                      to: :construction_demolition_form,
                      if: %i[lower_tier? only_carries_own_waste?]

          transitions from: :company_name_form,
                      to: :waste_types_form,
                      if: %i[lower_tier? waste_is_main_service?]

          transitions from: :company_name_form,
                      to: :construction_demolition_form,
                      if: %i[lower_tier?]

          transitions from: :company_name_form,
                      to: :cbd_type_form,
                      if: :skip_registration_number?

          transitions from: :company_name_form,
                      to: :registration_number_form

          transitions from: :other_businesses_form,
                      to: :location_form,
                      if: :overseas?

          transitions from: :other_businesses_form,
                      to: :business_type_form

          transitions from: :service_provided_form,
                      to: :other_businesses_form

          transitions from: :waste_types_form,
                      to: :service_provided_form

          transitions from: :construction_demolition_form,
                      to: :other_businesses_form,
                      if: :only_carries_own_waste?

          transitions from: :construction_demolition_form,
                      to: :service_provided_form

          transitions from: :cbd_type_form,
                      to: :waste_types_form,
                      if: :not_only_amf?

          transitions from: :cbd_type_form,
                      to: :construction_demolition_form

          # End smart answers

          transitions from: :registration_number_form,
                      to: :cbd_type_form

          # Registered address

          transitions from: :company_postcode_form,
                      to: :company_name_form

          transitions from: :company_address_form,
                      to: :company_postcode_form

          transitions from: :company_address_manual_form,
                      to: :company_name_form,
                      if: :overseas?

          transitions from: :company_address_manual_form,
                      to: :company_postcode_form

          transitions from: :main_people_form,
                      to: :company_address_manual_form,
                      if: :registered_address_was_manually_entered?

          transitions from: :main_people_form,
                      to: :company_address_form

          # End registered address

          transitions from: :declare_convictions_form,
                      to: :main_people_form

          transitions from: :conviction_details_form,
                      to: :declare_convictions_form

          transitions from: :contact_name_form,
                      to: :company_address_manual_form,
                      if: %i[lower_tier? registered_address_was_manually_entered?]

          transitions from: :contact_name_form,
                      to: :company_address_form,
                      if: :lower_tier?

          transitions from: :contact_name_form,
                      to: :conviction_details_form,
                      if: :declared_convictions?

          transitions from: :contact_name_form,
                      to: :declare_convictions_form

          transitions from: :contact_phone_form,
                      to: :contact_name_form

          transitions from: :contact_email_form,
                      to: :contact_phone_form

          # Contact address

          transitions from: :contact_postcode_form,
                      to: :contact_email_form

          transitions from: :contact_address_form,
                      to: :contact_postcode_form

          transitions from: :contact_address_manual_form,
                      to: :contact_email_form,
                      if: :overseas?

          transitions from: :contact_address_manual_form,
                      to: :contact_postcode_form

          transitions from: :check_your_answers_form,
                      to: :contact_address_manual_form,
                      if: :contact_address_was_manually_entered?

          transitions from: :check_your_answers_form,
                      to: :contact_address_form

          # End contact address

          transitions from: :declaration_form,
                      to: :check_your_answers_form

          transitions from: :cards_form,
                      to: :declaration_form

          transitions from: :payment_summary_form,
                      to: :cards_form

          transitions from: :worldpay_form,
                      to: :payment_summary_form

          transitions from: :bank_transfer_form,
                      to: :payment_summary_form
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

      def declared_convictions?
        # TODO: Make this a boolean
        declared_convictions == "yes"
      end

      def paying_by_card?
        temp_payment_method == "card"
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
    end
    # rubocop:enable Metrics/BlockLength
  end
  # rubocop:enable Metrics/ModuleLength
end
