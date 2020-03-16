# frozen_string_literal: true

module WasteCarriersEngine
  class EditRegistration < TransientRegistration
    include CanCheckIfRegistrationTypeChanged
    include CanCopyDataFromRegistration
    include CanUseEditRegistrationWorkflow
    include CanUseLock

    validates :reg_identifier, "waste_carriers_engine/reg_identifier": true

    COPY_DATA_OPTIONS = {
      ignorable_attributes: %w[_id
                               account_email
                               addresses
                               key_people
                               financeDetails
                               conviction_search_result
                               conviction_sign_offs
                               declaration
                               past_registrations
                               copy_cards],
      copy_addresses: true,
      copy_people: true
    }.freeze

    def registration
      @_registration ||= Registration.find_by(reg_identifier: reg_identifier)
    end
  end
end
