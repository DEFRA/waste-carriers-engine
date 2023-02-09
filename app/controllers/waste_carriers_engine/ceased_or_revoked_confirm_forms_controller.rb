# frozen_string_literal: true

module WasteCarriersEngine
  class CeasedOrRevokedConfirmFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(CeasedOrRevokedConfirmForm, "ceased_or_revoked_confirm_form")
    end

    def create
      find_or_initialize_transient_registration(params[:token])

      CeasedOrRevokedCompletionService.run(transient_registration: @transient_registration, user: current_user)

      status = @transient_registration.status
      ceased_or_revoked = I18n.t(
        "waste_carriers_engine.ceased_or_revoked_confirm_forms.create.ceased_or_revoked.#{status}"
      )

      message = I18n.t(
        "waste_carriers_engine.ceased_or_revoked_confirm_forms.create.submit_message",
        reg_identifier: @transient_registration.reg_identifier,
        ceased_or_revoked: ceased_or_revoked
      )

      flash[:message] = message

      redirect_to("/bo")
    end
  end
end
