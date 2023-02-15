# frozen_string_literal: true

module WasteCarriersEngine
  class DeregisteringRegistration < TransientRegistration
    include CanUseDeregistrationWorkflow

    validates :reg_identifier, "waste_carriers_engine/reg_identifier": true

    delegate :contact_email, :company_name, to: :registration

    field :temp_confirm_deregistration, type: String

    def registration
      @_registration ||= Registration.find_by(reg_identifier: reg_identifier)
    end

    def can_be_deregistered?
      registration.active? && registration.lower_tier?
    end
  end
end
