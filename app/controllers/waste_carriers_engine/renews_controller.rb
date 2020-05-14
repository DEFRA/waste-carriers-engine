# frozen_string_literal: true

module WasteCarriersEngine
  class RenewsController < ApplicationController
    include CanRedirectFormToCorrectPath

    before_action :validate_renew_token

    def new
      @transient_registration = fetch_transient_renewal
      @transient_registration.update_attributes(from_magic_link: true)

      redirect_to_correct_form
    end

    private

    def validate_renew_token
      return render(:already_renewed) if registration.already_renewed?
      return render(:past_renewal_window) if registration.past_renewal_window?

      # TODO
      # return render(:invalid_magic_link, status: 404) unless registration.present?
    end

    def registration
      @registration ||= Registration.find_by(renew_token: params[:token])
    end

    def fetch_transient_renewal
      registration.renewal || new_renewal_from_magic_link
    end

    def new_renewal_from_magic_link
      RenewingRegistration.create(reg_identifier: registration.reg_identifier)
    end
  end
end
