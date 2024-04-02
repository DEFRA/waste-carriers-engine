# frozen_string_literal: true

module WasteCarriersEngine
  class UnsubscribeLinkService < BaseService
    def run(registration:)
      # don't use routes.url_helpers as that includes "/bo" when
      # called from the back office
      [
        Rails.configuration.wcrs_fo_link_domain,
        "/fo/unsubscribe/",
        registration.unsubscribe_token
      ].join
    end
  end
end
