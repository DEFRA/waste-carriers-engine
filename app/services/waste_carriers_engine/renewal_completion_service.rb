module WasteCarriersEngine
  class RenewalCompletionService
    def initialize(transient_registration)
      @transient_registration = transient_registration
      @registration = find_original_registration
    end

    def complete_renewal
      return :error unless valid_renewal?
      create_past_registration
      update_registration
      delete_transient_registration
    end

    private

    def find_original_registration
      Registration.where(reg_identifier: @transient_registration.reg_identifier).first
    end

    def valid_renewal?
      @registration.metaData.may_renew?
    end

    def create_past_registration
      PastRegistration.build_past_registration(@registration)
    end

    def update_registration
      copy_data_from_transient_registration
      merge_finance_details
      @registration.metaData.route = "DIGITAL"
      @registration.metaData.renew
      @registration.save!
    end

    def delete_transient_registration
      @transient_registration.delete
    end

    def copy_data_from_transient_registration
      attributes = @transient_registration.attributes.except("_id",
                                                             "financeDetails",
                                                             "temp_cards",
                                                             "temp_company_postcode",
                                                             "temp_contact_postcode",
                                                             "temp_os_places_error",
                                                             "temp_payment_method",
                                                             "temp_tier_check",
                                                             "workflow_state")
      @registration.write_attributes(attributes)

      # If attributes aren't included in the transient_registration, for example if the user skipped the tier check,
      # update those attributes to be nil for the registration
      registration_attributes = @registration.attributes.except("_id", "financeDetails", "past_registrations").keys
      registration_attributes.each do |attribute|
        next if attributes.keys.include?(attribute)
        @registration[attribute] = nil
      end
    end

    def merge_finance_details
      set_up_finance_details(@registration)
      set_up_finance_details(@transient_registration)

      @transient_registration.finance_details.orders.each do |order|
        @registration.finance_details.orders << order
      end

      @transient_registration.finance_details.payments.each do |payment|
        @registration.finance_details.payments << payment
      end

      @registration.finance_details.update_balance
    end

    # If for some reason we have no existing finance info, create empty objects
    def set_up_finance_details(registration)
      registration.finance_details = FinanceDetails.new unless registration.finance_details.present?
      set_up_orders(registration)
      set_up_payments(registration)
    end

    def set_up_orders(registration)
      registration.finance_details.orders = [] unless registration.finance_details.orders.present?
    end

    def set_up_payments(registration)
      registration.finance_details.payments = [] unless registration.finance_details.payments.present?
    end
  end
end
