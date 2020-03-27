# frozen_string_literal: true

module WasteCarriersEngine
  class RegistrationCompletionService < BaseService
    attr_reader :transient_registration

    def run(transient_registration)
      @transient_registration = transient_registration

      transient_registration.with_lock do
        copy_names_to_contact_address
        copy_data_from_transient_registration

        set_reg_identifier
        set_expiry_date

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

    def send_confirmation_email
      # TODO
      # Note that we will only send emails here if the registration has pending convictions or pending payments.
      # In the case when the registration can be completed, the registration activation email is sent from
      # the RegistrationActivationService.
    rescue StandardError => e
      Airbrake.notify(e, registration_no: registration.reg_identifier) if defined?(Airbrake)
    end

    def set_reg_identifier
      registration.reg_identifier = transient_registration.reg_identifier
    end

    def copy_data_from_transient_registration
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
        "_type",
        "workflow_state",
        "locking_name",
        "locked_at"
      )

      registration.write_attributes(new_attributes)
    end
  end
end
