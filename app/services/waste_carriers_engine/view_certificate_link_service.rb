# frozen_string_literal: true

module WasteCarriersEngine
  class ViewCertificateLinkService < BaseService
    def run(registration:, renew_token: false)
      @registration = registration
      @renew_token = renew_token

      [
        Rails.configuration.wcrs_fo_link_domain,
        "/fo/",
        @registration.reg_identifier,
        "/certificate?token=",
        view_certificate_token
      ].join
    end

    private

    attr_reader :registration, :renew_token

    def view_certificate_token
      if renew_token || registration.view_certificate_token.blank?
        registration.generate_view_certificate_token!
      else
        registration.view_certificate_token
      end
    end
  end
end
