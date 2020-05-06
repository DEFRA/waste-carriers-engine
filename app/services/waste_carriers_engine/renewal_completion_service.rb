# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalCompletionService
    class CannotComplete < StandardError; end
    class StillUnpaidBalance < StandardError; end
    class WrongWorkflowState < StandardError; end
    class PendingConvictionCheck < StandardError; end
    class WrongStatus < StandardError; end

    include CanMergeFinanceDetails

    attr_reader :transient_registration

    def initialize(transient_registration)
      @transient_registration = transient_registration
    end

    def can_be_completed?
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
          delete_transient_registration
          send_confirmation_email
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
      merge_finance_details
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

    def delete_transient_registration
      transient_registration.delete
    end

    def send_confirmation_email
      RenewalMailer.send_renewal_complete_email(registration).deliver_now
    rescue StandardError => e
      Airbrake.notify(e, registration_no: registration.reg_identifier) if defined?(Airbrake)
    end

    def copy_data_from_transient_registration
      registration_attributes = registration.attributes.except("_id", "financeDetails", "past_registrations")
      renewal_attributes = transient_registration.attributes.except("_id",
                                                                    "token",
                                                                    "created_at",
                                                                    "financeDetails",
                                                                    "temp_cards",
                                                                    "temp_company_postcode",
                                                                    "temp_contact_postcode",
                                                                    "temp_os_places_error",
                                                                    "temp_payment_method",
                                                                    "temp_tier_check",
                                                                    "from_magic_link",
                                                                    "_type",
                                                                    "workflow_state",
                                                                    "locking_name",
                                                                    "locked_at")

      remove_unused_attributes(registration_attributes, renewal_attributes)

      registration.write_attributes(renewal_attributes)
    end

    def remove_unused_attributes(registration_attributes, renewal_attributes)
      registration_attributes.each_key do |old_attribute|
        # If attributes aren't included in the transient_registration, for example if the user skipped the tier check,
        # remove those attributes from the registration instead of leaving the existing values
        next if renewal_attributes.key?(old_attribute)

        registration.remove_attribute(old_attribute.to_sym)
      end
    end
  end
end
