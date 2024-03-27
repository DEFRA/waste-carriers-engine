# frozen_string_literal: true

module WasteCarriersEngine
  # rubocop:disable Metrics/ClassLength
  class RegistrationCompletionService < BaseService
    include CanAddDebugLogging

    attr_reader :transient_registration

    # rubocop:disable Metrics/MethodLength
    def run(transient_registration)
      @transient_registration = transient_registration

      transient_registration.with_lock do
        prepare_finance_details_for_lower_tier

        copy_names_to_contact_address
        copy_data_from_transient_registration
        copy_key_people_from_transient_registration
        copy_conviction_sign_offs_from_transient_registration

        set_reg_identifier
        set_expiry_date if registration.upper_tier?

        update_meta_data

        registration.increment_certificate_version

        registration.save!

        delete_transient_registration
        send_confirmation_email

        begin
          RegistrationActivationService.run(registration: registration)
        rescue StandardError => e
          log_transient_registration_details("Exception running RegistrationCompletionService",
                                             e, @transient_registration)
          Airbrake.notify(e, reg_identifier: @transient_registration.reg_identifier)
          Rails.logger.error e
        end
      end

      registration
    end
    # rubocop:enable Metrics/MethodLength

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

    def copy_conviction_sign_offs_from_transient_registration
      # Only copy conviction sign offs if the user has applied for upper tier
      return unless transient_registration.upper_tier?

      registration.conviction_search_result = transient_registration.conviction_search_result
      registration.conviction_sign_offs = transient_registration.conviction_sign_offs
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
      if registration.pending_online_payment?
        send_online_pending_payment_email
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

    def send_online_pending_payment_email
      Notify::RegistrationPendingOnlinePaymentEmailService.run(registration: registration)
    end

    def send_pending_conviction_check_email
      Notify::RegistrationPendingConvictionCheckEmailService.run(registration: registration)
    end

    def set_reg_identifier
      registration.reg_identifier = transient_registration.reg_identifier
    end

    def copy_data_from_transient_registration
      # Make sure data are loaded into attributes if set on this instance
      transient_registration.reload

      do_not_copy_attributes = %w[
        _id
        conviction_search_result
        conviction_sign_offs
        created_at
        key_people
        locked_at
        locking_name
        reg_identifier
        token
        _type
        workflow_history
        workflow_state
      ].concat(WasteCarriersEngine::NewRegistration.temp_attributes)

      registration.write_attributes(copyable_attributes(do_not_copy_attributes))
    end

    def copyable_attributes(do_not_copy_attributes)
      SafeCopyAttributesService.run(
        source_instance: transient_registration,
        target_class: Registration,
        embedded_documents: %w[addresses metaData financeDetails],
        attributes_to_exclude: do_not_copy_attributes
      )
    end
  end
  # rubocop:enable Metrics/ClassLength
end
