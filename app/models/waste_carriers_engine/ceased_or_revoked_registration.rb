# frozen_string_literal: true

module WasteCarriersEngine
  class CeasedOrRevokedRegistration < TransientRegistration
    include CanUseCeasedOrRevokedRegistrationWorkflow

    validates :reg_identifier, "waste_carriers_engine/reg_identifier": true

    delegate :status, to: :registration

    def registration
      @_registration ||= Registration.find_by(reg_identifier: reg_identifier)
    end
  end
end
