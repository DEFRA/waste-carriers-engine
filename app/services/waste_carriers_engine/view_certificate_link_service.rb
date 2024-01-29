# frozen_string_literal: true

module WasteCarriersEngine
  class ViewCertificateLinkService < BaseService
    def run(registration:)
      [
        Rails.configuration.wcrs_fo_link_domain,
        "/fo/",
        registration.reg_identifier,
        "/certificate?token=",
        registration.view_certificate_token
      ].join
    end
  end
end
