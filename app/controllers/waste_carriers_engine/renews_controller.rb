# frozen_string_literal: true

module WasteCarriersEngine
  class RenewsController < ApplicationController
    before_action :validate_renew_token

    def new
      # TODO: Should create a renewing registation
      # @transient_registration = RenewingRegistration.create(reg_identifier: registration.reg_identifier)

      # TODO: Should redirect to start renewing registration journey
      render text: "OK - I am a renew via magic link page - renewing #{registration.reg_identifier}"
    end

    private

    def validate_renew_token
      # TODO
      # return render(:invalid_magic_link, status: 404) unless registration.present?
      # return render(:already_renewed) if registration.already_renewed?
      # return render(:past_renewal_window) if registration.past_renewal_window?
    end

    def registration
      @registration ||= Registration.find_by(renew_token: params[:token])
    end
  end
end
