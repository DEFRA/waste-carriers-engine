# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module WasteCarriersEngine
  class RenewalCompletionService
    class CannotComplete < StandardError; end
    class StillUnpaidBalance < StandardError; end
    class WrongWorkflowState < StandardError; end
    class PendingConvictionCheck < StandardError; end
    class WrongStatus < StandardError; end

    attr_reader :transient_registration

    def initialize(transient_registration)
      @transient_registration = transient_registration
    end

    def can_be_completed?
      transient_registration.reload
      return false unless transient_registration.ready_to_complete?
      # We check the status of the transient registration as part of its
      # can_be_renewed? method and this is sufficient during the application.
      # However during that period there is a possibility that the registration
      # has since been REVOKED so we perform this additional check against the
      # underlying registration just to be sure we are not allowing a renewal
      # for a REVOKED registration to complete
      return false unless %w[ACTIVE EXPIRED].include?(registration.metaData.status)

      true
    end

    def complete_renewal
      raise_completion_error unless can_be_completed?

      registration.with_lock do
        transient_registration.with_lock do
          copy_names_to_contact_address
          create_past_registration
          update_registration
          increment_certificate_version
          create_order_item_logs
          delete_transient_registration
          generate_view_certificate_token
          send_confirmation_messages
        end
      end
    end

    private

    def registration
      @registration ||= Registration.where(reg_identifier: transient_registration.reg_identifier).first
    end

    def raise_completion_error
      # TODO: Temporaty debugging code for issue https://eaflood.atlassian.net/browse/RUBY-885
      message = "Registration number: #{transient_registration.reg_identifier}"

      raise(WrongWorkflowState, message) unless transient_registration.renewal_application_submitted?
      raise(StillUnpaidBalance, message) if transient_registration.unpaid_balance?
      raise(PendingConvictionCheck, message) if transient_registration.pending_manual_conviction_check?

      unless %w[ACTIVE EXPIRED].include?(registration.metaData.status)
        message = "#{message}. Status: #{registration.metaData.status}"
        raise(WrongStatus, message)
      end

      raise(CannotComplete, message)
    end

    def copy_names_to_contact_address
      transient_registration.contact_address.first_name = transient_registration.first_name
      transient_registration.contact_address.last_name = transient_registration.last_name
    end

    def create_past_registration
      PastRegistration.build_past_registration(registration)
    end

    def update_registration
      copy_data_from_transient_registration
      MergeFinanceDetailsService.call(registration:, transient_registration:)
      extend_expiry_date
      update_meta_data
      registration.save!
    end

    def update_meta_data
      registration.metaData.route = transient_registration.metaData.route
      registration.metaData.renew
      registration.metaData.date_registered = Time.now
      registration.metaData.date_activated = registration.metaData.date_registered
    end

    def extend_expiry_date
      expiry_check_service = ExpiryCheckService.new(registration)
      registration.expires_on = expiry_check_service.expiry_date_after_renewal
    end

    def create_order_item_logs
      OrderItemLog.create_from_registration(transient_registration)
    end

    def delete_transient_registration
      transient_registration.delete
    end

    def send_confirmation_messages
      send_confirmation_letter unless registration.contact_email.present?

      send_confirmation_email
    end

    def send_confirmation_letter
      Notify::RenewalConfirmationLetterService.run(registration: registration)
    rescue StandardError => e
      Airbrake.notify(e, registration_no: registration.reg_identifier) if defined?(Airbrake)
      Rails.logger.error "Confirmation letter error: #{e}"
    end

    def send_confirmation_email
      Notify::RenewalConfirmationEmailService.run(registration: registration)
    rescue StandardError => e
      Airbrake.notify(e, registration_no: registration.reg_identifier) if defined?(Airbrake)
    end

    # rubocop:disable Metrics/MethodLength
    def copy_data_from_transient_registration
      registration_attributes = registration.attributes.except(
        "_id",
        "financeDetails",
        "past_registrations",
        "renew_token",
        "unsubscribe_token",
        "deregistration_token",
        "deregistration_token_created_at",
        "view_certificate_token",
        "view_certificate_token_created_at"
      )

      do_not_copy_attributes = %w[
        _id
        token
        created_at
        financeDetails
        from_magic_link
        _type
        workflow_state
        workflow_history
        locking_name
        locked_at
      ].concat(WasteCarriersEngine::RenewingRegistration.temp_attributes)

      renewal_attributes = SafeCopyAttributesService.run(
        source_instance: transient_registration,
        target_class: Registration,
        attributes_to_exclude: do_not_copy_attributes
      )

      remove_unused_attributes(registration_attributes, renewal_attributes)

      registration.write_attributes(renewal_attributes)
    end
    # rubocop:enable Metrics/MethodLength

    def remove_unused_attributes(registration_attributes, renewal_attributes)
      registration_attributes.each_key do |old_attribute|
        # If attributes aren't included in the transient_registration, for example if the user skipped the tier check,
        # remove those attributes from the registration instead of leaving the existing values
        next if renewal_attributes.key?(old_attribute)

        registration.remove_attribute(old_attribute.to_sym)
      end
    end

    def increment_certificate_version
      registration.increment_certificate_version
    end

    def generate_view_certificate_token
      return if registration.view_certificate_token.present?

      registration.generate_view_certificate_token!
    end
  end
end
# rubocop:enable Metrics/ClassLength
