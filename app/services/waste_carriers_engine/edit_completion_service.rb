# frozen_string_literal: true

module WasteCarriersEngine
  class EditCompletionService < BaseService
    def run(edit_registration:)
      @edit_registration = edit_registration
      @registration = @edit_registration.registration

      copy_data_to_registration
      delete_transient_registration
    end

    private

    def copy_data_to_registration
      copy_attributes
      @registration.save!
    end

    def delete_transient_registration
      @edit_registration.delete
    end

    def copy_attributes
      copyable_attributes = @edit_registration.attributes.except("_id",
                                                                 "token",
                                                                 "account_email",
                                                                 "created_at",
                                                                 "financeDetails",
                                                                 "temp_cards",
                                                                 "temp_company_postcode",
                                                                 "temp_contact_postcode",
                                                                 "temp_os_places_error",
                                                                 "temp_payment_method",
                                                                 "temp_tier_check",
                                                                 "_type",
                                                                 "workflow_state")

      @registration.write_attributes(copyable_attributes)
    end
  end
end
