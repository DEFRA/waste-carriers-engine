# frozen_string_literal: true

module WasteCarriersEngine
  class CertificatesController < ::WasteCarriersEngine::ApplicationController
    before_action :find_registration
    before_action :ensure_valid_email, only: %i[show pdf]
    before_action :ensure_valid_token, only: %i[confirm_email show pdf]

    layout "application"

    UserStruct = Struct.new(:email)

    def show
      @presenter = build_presenter
    end

    def pdf
      @presenter = build_presenter
      render pdf_settings
    end

    def confirm_email
      # to render the confirm_email view, with registration from before_action
    end

    def process_email
      email = params[:email]
      unless valid_email?(email)
        flash[:error] = I18n.t(".waste_carriers_engine.certificates.process_email.error")
        render :confirm_email and return
      end

      session[:valid_email] = email
      redirect_to certificate_path(@registration.reg_identifier,
                                   token: @registration.view_certificate_token)
    end

    private

    def ensure_valid_email
      return if valid_email?(session[:valid_email])

      redirect_to confirm_email_path
    end

    def build_presenter
      WasteCarriersEngine::CertificateGeneratorService.run(
        registration: @registration,
        requester: current_user_struct,
        view: view_context
      )
    end

    def pdf_settings
      {
        pdf: @registration.reg_identifier,
        layout: false,
        page_size: "A4",
        margin: { top: "10mm", bottom: "10mm", left: "10mm", right: "10mm" },
        print_media_type: true,
        template: "waste_carriers_engine/pdfs/certificate",
        enable_local_file_access: true,
        allow: [WasteCarriersEngine::Engine.root.join("app", "assets", "images",
                                                      "environment_agency_logo.png").to_s]
      }
    end

    def find_registration
      @registration = WasteCarriersEngine::Registration.find_by(reg_identifier: params[:reg_identifier])
      redirect_to "/" unless @registration
    end

    def valid_email?(email)
      [@registration.contact_email, @registration.receipt_email].compact.include?(email)
    end

    def current_user_struct
      UserStruct.new(session[:valid_email])
    end

    def confirm_email_path
      certificate_confirm_email_path(@registration.reg_identifier)
    end

    def ensure_valid_token
      return if valid_token?

      redirect_to "/", notice: I18n.t(".waste_carriers_engine.certificates.errors.token")
    end

    def valid_token?
      return false unless params[:token].present? && @registration.view_certificate_token_valid?

      params[:token] == @registration.view_certificate_token
    end
  end
end
