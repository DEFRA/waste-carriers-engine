# frozen_string_literal: true

module WasteCarriersEngine
  class DeregistrationMagicLinkService < BaseService
    def run(registration:)
      [
        Rails.configuration.wcrs_fo_link_domain,
        "/fo/deregister/",
        registration.generate_deregistration_token
      ].join
    end
  end
end
