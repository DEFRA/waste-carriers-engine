# frozen_string_literal: true

module WasteCarriersEngine
  class EditRegistration < TransientRegistration
    include CanCopyDataFromRegistration
    include CanUseEditRegistrationWorkflow

    validates :reg_identifier, "waste_carriers_engine/reg_identifier": true

    def registration
      @_registration ||= Registration.find_by(reg_identifier: reg_identifier)
    end
  end
end
