# frozen_string_literal: true

module WasteCarriersEngine
  class EditCompletionService < BaseService
    include CanMergeFinanceDetails

    attr_reader :transient_registration

    delegate :registration, to: :transient_registration

    def run(edit_registration:)
      @transient_registration = edit_registration

      copy_names_to_contact_address
      create_past_registration
      copy_data_to_registration
      delete_transient_registration
    end

    private

    def copy_names_to_contact_address
      transient_registration.contact_address.first_name = transient_registration.first_name
      transient_registration.contact_address.last_name = transient_registration.last_name
    end

    def create_past_registration
      PastRegistration.build_past_registration(registration, :edit)
    end

    def copy_data_to_registration
      merge_finance_details if transient_registration.registration_type_changed?
      copy_attributes
      registration.save!
    end

    def delete_transient_registration
      transient_registration.delete
    end

    def copy_attributes
      copyable_attributes = transient_registration.attributes.except("_id",
                                                                     "token",
                                                                     "account_email",
                                                                     "created_at",
                                                                     "expires_on",
                                                                     "financeDetails",
                                                                     "temp_cards",
                                                                     "temp_company_postcode",
                                                                     "temp_contact_postcode",
                                                                     "temp_os_places_error",
                                                                     "temp_payment_method",
                                                                     "temp_tier_check",
                                                                     "_type",
                                                                     "workflow_state")

      registration.write_attributes(copyable_attributes)
    end
  end
end
