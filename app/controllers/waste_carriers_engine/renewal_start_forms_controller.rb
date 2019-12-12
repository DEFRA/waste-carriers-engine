# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalStartFormsController < FormsController
    def new
      super(RenewalStartForm, "renewal_start_form")
    end

    def create
      super(RenewalStartForm, "renewal_start_form")
    end

    private

    def find_or_initialize_transient_registration(token)
      # TODO: Downtime at deploy when releasing token?
      @transient_registration = RenewingRegistration.where(token: token).first ||
                                RenewingRegistration.where(reg_identifier: token).first ||
                                RenewingRegistration.new(reg_identifier: token)
    end
  end
end
