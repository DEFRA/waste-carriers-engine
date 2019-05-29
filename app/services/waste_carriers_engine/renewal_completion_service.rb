# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalCompletionService
    def initialize(transient_registration)
      @transient_registration = transient_registration
      @registration = find_original_registration
    end

    def can_be_completed?
      return false unless @transient_registration.ready_to_complete?
      # We check the status of the transient registration as part of its
      # can_be_renewed? method and this is sufficient during the application.
      # However during that period there is a possibility that the registration
      # has since been REVOKED so we perform this additional check against the
      # underlying registration just to be sure we are not allowing a renewal
      # for a REVOKED registration to complete
      return false unless %w[ACTIVE EXPIRED].include?(@registration.metaData.status)

      true
    end

    def complete_renewal
      return :error unless can_be_completed?

      copy_names_to_contact_address
      create_past_registration
      update_registration
      delete_transient_registration
      send_confirmation_email
    end

    private

    def find_original_registration
      Registration.where(reg_identifier: @transient_registration.reg_identifier).first
    end

    def copy_names_to_contact_address
      @transient_registration.contact_address.first_name = @transient_registration.first_name
      @transient_registration.contact_address.last_name = @transient_registration.last_name
    end

    def create_past_registration
      PastRegistration.build_past_registration(@registration)
    end

    def update_registration
      copy_data_from_transient_registration
      merge_finance_details
      extend_expiry_date
      update_meta_data
      @registration.save!
    end

    def update_meta_data
      @registration.metaData.route = Rails.configuration.metadata_route
      @registration.metaData.renew
      @registration.metaData.date_registered = Time.now
      @registration.metaData.date_activated = @registration.metaData.date_registered
    end

    def extend_expiry_date
      expiry_check_service = ExpiryCheckService.new(@registration)
      @registration.expires_on = expiry_check_service.expiry_date_after_renewal
    end

    def delete_transient_registration
      @transient_registration.delete
    end

    def send_confirmation_email
      RenewalMailer.send_renewal_complete_email(@registration).deliver_now
    rescue StandardError => e
      Airbrake.notify(e, registration_no: @registration.reg_identifier) if defined?(Airbrake)
    end

    def copy_data_from_transient_registration
      registration_attributes = @registration.attributes.except("_id", "financeDetails", "past_registrations")
      renewal_attributes = @transient_registration.attributes.except("_id",
                                                                     "financeDetails",
                                                                     "temp_cards",
                                                                     "temp_company_postcode",
                                                                     "temp_contact_postcode",
                                                                     "temp_os_places_error",
                                                                     "temp_payment_method",
                                                                     "temp_tier_check",
                                                                     "workflow_state")

      remove_unused_attributes(registration_attributes, renewal_attributes)

      @registration.write_attributes(renewal_attributes)
    end

    def remove_unused_attributes(registration_attributes, renewal_attributes)
      registration_attributes.keys.each do |old_attribute|
        # If attributes aren't included in the transient_registration, for example if the user skipped the tier check,
        # remove those attributes from the registration instead of leaving the existing values
        next if renewal_attributes.key?(old_attribute)

        @registration.remove_attribute(old_attribute.to_sym)
      end
    end

    def merge_finance_details
      initialize_finance_details(@registration)
      initialize_finance_details(@transient_registration)

      @transient_registration.finance_details.orders.each do |order|
        @registration.finance_details.orders << order
      end

      @transient_registration.finance_details.payments.each do |payment|
        @registration.finance_details.payments << payment
      end

      @registration.finance_details.update_balance
    end

    # If for some reason we have no existing finance info, create empty objects
    def initialize_finance_details(registration)
      registration.finance_details = FinanceDetails.new unless registration.finance_details.present?
      initialize_orders(registration)
      initialize_payments(registration)
    end

    def initialize_orders(registration)
      registration.finance_details.orders = [] unless registration.finance_details.orders.present?
    end

    def initialize_payments(registration)
      registration.finance_details.payments = [] unless registration.finance_details.payments.present?
    end
  end
end
