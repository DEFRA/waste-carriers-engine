# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class CertificateRenewalEmailService < BaseSendEmailService
      include WasteCarriersEngine::ApplicationHelper
      include WasteCarriersEngine::CanRecordCommunication

      LOWER_TIER_TEMPLATE_ID = "67610f90-3fb3-4e9c-b198-8ec21f695df0"
      LOWER_TIER_COMMS_LABEL = "Lower tier registration complete - html certificate"

      UPPER_TIER_TEMPLATE_ID = "25abd90b-accf-488e-8156-c456d557b41a"
      UPPER_TIER_COMMS_LABEL = "Upper tier registration complete - html certificate"

      private

      def template_id
        @registration.upper_tier? ? UPPER_TIER_TEMPLATE_ID : LOWER_TIER_TEMPLATE_ID
      end

      def comms_label
        @registration.upper_tier? ? UPPER_TIER_COMMS_LABEL : LOWER_TIER_COMMS_LABEL
      end

      def personalisation
        {
          registration_type: registration_type,
          reg_identifier: @registration.reg_identifier,
          first_name: @registration.first_name,
          last_name: @registration.last_name,
          registered_address: registered_address,
          date_registered: @registration.metaData.date_registered,
          link_to_file: link_to_file
        }
      end

      def registration_type
        return unless @registration.upper_tier?

        I18n.t(
          "waste_carriers_engine.registration_type.upper.#{@registration.registration_type}"
        )
      end

      def link_to_file
        return unless @registration.view_certificate_token

        certificate_url(@registration.reg_identifier, token: @registration.view_certificate_token)
      end

      def registered_address
        displayable_address(@registration.contact_address).join(", ")
      end

      def date_registered
        @registration.metaData.date_registered.in_time_zone("London").to_date.to_s(:standard)
      end
    end
  end
end
