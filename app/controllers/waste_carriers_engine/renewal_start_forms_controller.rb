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

    def find_or_initialize_transient_registration(id)
      @transient_registration = RenewingRegistration.where(_id: id).first ||
                                RenewingRegistration.where(reg_identifier: id).first ||
                                RenewingRegistration.new(reg_identifier: id)
    end
  end
end
