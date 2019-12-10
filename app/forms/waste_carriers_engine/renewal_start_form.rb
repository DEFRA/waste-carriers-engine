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

    def find_or_initialize_transient_registration(token)
      # TODO: Downtime at deploy when releasing token?
      @transient_registration = RenewingRegistration.where(token: token).first ||
                                RenewingRegistration.new(reg_identifier: token)
    end
  end
end
