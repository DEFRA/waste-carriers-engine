# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalStartFormsController < ::WasteCarriersEngine::FormsController
    prepend_before_action :authenticate_user!, if: :should_authenticate_user?

    def new
      if !@transient_registration.from_magic_link &&
         WasteCarriersEngine::FeatureToggle.active?(:block_front_end_logins) &&
         !WasteCarriersEngine.configuration.host_is_back_office?
        redirect_to "/"
        return
      end

      # If the renewing_registration has an invalid workflow_state, reset it to the first form after renewal_start_form
      unless @transient_registration.may_next?
        @transient_registration.update_attributes(workflow_state: "location_form")
      end

      super(RenewalStartForm, "renewal_start_form")
    end

    def create
      super(RenewalStartForm, "renewal_start_form")
    end

    private

    def find_or_initialize_transient_registration(token)
      @transient_registration = RenewingRegistration.where(token: token).first ||
                                RenewingRegistration.where(reg_identifier: token).first ||
                                RenewingRegistration.new(reg_identifier: token)
    end

    def should_authenticate_user?
      return false if WasteCarriersEngine::FeatureToggle.active?(:block_front_end_logins)

      find_or_initialize_transient_registration(params[:token])

      return false if @transient_registration.from_magic_link

      true
    end
  end
end
