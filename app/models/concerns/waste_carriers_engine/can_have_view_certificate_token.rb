# frozen_string_literal: true

module WasteCarriersEngine
  module CanHaveViewCertificateToken
    extend ActiveSupport::Concern
    include CanGenerateAndValidateToken

    DEFAULT_TOKEN_VALIDITY_PERIOD = 28 # days

    included do
      field :view_certificate_token, type: String
      field :view_certificate_token_created_at, type: DateTime
    end

    def generate_view_certificate_token!
      generate_token(:view_certificate_token, :view_certificate_token_created_at)
    end

    def view_certificate_token_valid?
      validity_period = ENV.fetch("WCRS_VIEW_CERTIFICATE_TOKEN_VALIDITY_PERIOD", DEFAULT_TOKEN_VALIDITY_PERIOD).to_i
      token_valid?(:view_certificate_token, :view_certificate_token_created_at, validity_period)
    end
  end
end
