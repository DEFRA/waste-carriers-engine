# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalStartFormsController < ::WasteCarriersEngine::FormsController
    prepend_before_action :authenticate_user!, if: :should_authenticate_user?

    def new
      super(RenewalStartForm, "renewal_start_form")
    end

    def create
      super(RenewalStartForm, "renewal_start_form")
    end

    private

    def find_or_initialize_transient_registration(token)
      @transient_registration ||= RenewingRegistration.where(token: token).first ||
                                  RenewingRegistration.where(reg_identifier: token).first ||
                                  RenewingRegistration.new(reg_identifier: token)

      # Any existing company name should not be used for a registration renewal where company_name is optional.
      @transient_registration.company_name = nil unless @transient_registration.company_name_required?

      @transient_registration
    end

    def should_authenticate_user?
      find_or_initialize_transient_registration(params[:token])

      return false if @transient_registration.from_magic_link

      true
    end
  end
end
