# frozen_string_literal: true

module WasteCarriersEngine
  class RegistrationCompletionService < BaseService
    attr_reader :transient_registration

    def run(transient_registration)
      @transient_registration = transient_registration

      transient_registration.with_lock do
        prepare_finance_details_for_lower_tier

        copy_names_to_contact_address
        copy_data_from_transient_registration
        copy_key_people_from_transient_registration

        set_reg_identifier
        set_expiry_date if registration.upper_tier?

        update_meta_data

        registration.save!

        delete_transient_registration
        send_confirmation_email

        begin
          RegistrationActivationService.run(registration: registration)
        rescue StandardError => e
          Airbrake.notify(e, reg_identifier: @transient_registration.reg_identifier)
          Rails.logger.error e
        end
      end

      registration
    end

    private

    def registration
      @_registration ||= Registration.new
    end

    def copy_names_to_contact_address
      transient_registration.contact_address.first_name = transient_registration.first_name
      transient_registration.contact_address.last_name = transient_registration.last_name
    end

    def copy_key_people_from_transient_registration
      # Only copy relevant people if the user has declared convictions
      return registration.key_people = transient_registration.key_people if transient_registration.declared_convictions?

      registration.key_people = transient_registration.main_people
    end

    def prepare_finance_details_for_lower_tier
      return if transient_registration.upper_tier?

      transient_registration.prepare_for_payment(:worldpay)
      transient_registration.reload
    end

    def update_meta_data
      registration.metaData.route = transient_registration.metaData.route
      registration.metaData.date_registered = Time.current
    end

    def set_expiry_date
      registration.expires_on = Rails.configuration.expires_after.years.from_now
    end

    def delete_transient_registration
      transient_registration.delete
    end

    # Note that we will only send emails here if the registration has pending convictions or pending payments.
    # In the case when the registration can be completed, the registration activation email is sent from
    # the RegistrationActivationService.
    def send_confirmation_email
      if registration.pending_worldpay_payment?
        send_worldpay_pending_payment_email
      elsif registration.unpaid_balance?
        send_pending_payment_email
      elsif registration.conviction_check_required?
        send_pending_conviction_check_email
      end
    rescue StandardError => e
      Airbrake.notify(e, registration_no: registration.reg_identifier) if defined?(Airbrake)
    end

    def send_pending_payment_email
      Notify::RegistrationPendingPaymentEmailService.run(registration: registration)
    end

    def send_worldpay_pending_payment_email
      Notify::RegistrationPendingWorldpayPaymentEmailService.run(registration: registration)
    end

    def send_pending_conviction_check_email
      Notify::RegistrationPendingConvictionCheckEmailService.run(registration: registration)
    end

    def set_reg_identifier
      registration.reg_identifier = transient_registration.reg_identifier
    end

    # rubocop:disable Metrics/MethodLength
    def copy_data_from_transient_registration
      # Make sure data are loaded into attributes if setted on this instance
      transient_registration.reload

      new_attributes = transient_registration.attributes.except(
        "_id",
        "reg_identifier",
        "token",
        "created_at",
        "temp_cards",
        "temp_company_postcode",
        "temp_start_option",
        "temp_contact_postcode",
        "temp_os_places_error",
        "temp_payment_method",
        "temp_lookup_number",
        "temp_tier_check",
        "temp_check_your_tier",
        "temp_reuse_registered_address",
        "_type",
        "workflow_state",
        "locking_name",
        "locked_at",
        "key_people"
      )

      registration.write_attributes(new_attributes)
    end
    # rubocop:enable Metrics/MethodLength
  end
end
