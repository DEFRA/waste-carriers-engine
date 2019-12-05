# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalStartForm < BaseForm
    def self.can_navigate_flexibly?
      false
    end

    def submit(_params)
      attributes = {}

      super(attributes)
    end

    def find_or_initialize_transient_registration(reg_identifier)
      # TODO: Downtime at deploy when releaasing token?
      @transient_registration = RenewingRegistration.where(token: reg_identifier).first ||
                                RenewingRegistration.new(reg_identifier: reg_identifier)
    end
  end
end
