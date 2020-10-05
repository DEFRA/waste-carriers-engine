# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalCompleteForm < ::WasteCarriersEngine::BaseForm
    include CannotSubmit

    attr_accessor :contact_email, :projected_renewal_end_date, :registration_type

    def self.can_navigate_flexibly?
      false
    end

    def initialize(transient_registration)
      super

      self.contact_email = transient_registration.contact_email
      self.projected_renewal_end_date = transient_registration.projected_renewal_end_date
      self.registration_type = transient_registration.registration_type
    end
  end
end
