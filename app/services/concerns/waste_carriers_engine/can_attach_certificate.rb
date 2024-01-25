# frozen_string_literal: true

module WasteCarriersEngine
  module CanAttachCertificate
    extend ActiveSupport::Concern
    include Rails.application.routes.url_helpers

    included do
      def link_to_certificate
        return unless @registration.view_certificate_token

        WasteCarriersEngine::Engine.routes.url_helpers.certificate_url(
          host: Rails.configuration.wcrs_frontend_url,
          reg_identifier: @registration.reg_identifier,
          token: @registration.view_certificate_token
        )
      end
    end
  end
end
