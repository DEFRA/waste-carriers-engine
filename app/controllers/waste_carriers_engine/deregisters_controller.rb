# frozen_string_literal: true

module WasteCarriersEngine
  class DeregistersController < ApplicationController

    before_action :validate_deregistration_token

    def new
      redirect_to new_deregistration_confirmation_form_path(registration.deregistration_token)
    end

    private

    def validate_deregistration_token
      return render(:invalid_deregistration_link, status: 404) unless registration.present?
      return render(:already_ceased, status: 422) unless registration.active?

      return if registration.deregistration_token_valid?

      Notify::DeregistrationEmailService.run(registration:)
      render(:deregistration_link_expired, status: 422)
    end

    def registration
      @registration ||= Registration.where(deregistration_token: params[:token]).first
    end
  end
end
