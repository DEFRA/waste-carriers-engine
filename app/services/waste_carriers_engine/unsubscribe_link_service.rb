# frozen_string_literal: true

module WasteCarriersEngine
  class UnsubscribeLinkService < BaseService
    def run(registration:)
      Rails.configuration.wcrs_fo_link_domain +
        WasteCarriersEngine::Engine
        .routes.url_helpers
        .unsubscribe_path(unsubscribe_token: registration.unsubscribe_token)
    end
  end
end
