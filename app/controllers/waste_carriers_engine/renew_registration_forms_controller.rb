# frozen_string_literal: true

module WasteCarriersEngine
  class RenewRegistrationFormsController < FormsController
    def new
      super(RenewRegistrationForm, "renew_registration_form")
    end

    def create
      return false unless set_up_form(RenewRegistrationForm, "renew_registration_form", params[:token])

      submit_form(@renew_registration_form, transient_registration_attributes)
    end

    private

    def transient_registration_attributes
      params.fetch(:renew_registration_form, {}).permit(:temp_lookup_number)
    end

    def submit_form(form, params)
      respond_to do |format|
        if form.submit(params)
          reset_magic_link_route

          format.html { redirect_to_renewal_journey }
          true
        else
          format.html { render :new }
          false
        end
      end
    end

    def redirect_to_renewal_journey
      redirect_to renewal_start_forms_path(token: @renew_registration_form.temp_lookup_number)
    end

    def reset_magic_link_route
      renewing_registration = WasteCarriersEngine::RenewingRegistration.where(
        reg_identifier: @renew_registration_form.temp_lookup_number
      ).first

      return unless renewing_registration

      renewing_registration.update_attributes(from_magic_link: false)
    end
  end
end
