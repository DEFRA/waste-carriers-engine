# frozen_string_literal: true

module WasteCarriersEngine
  module CanHaveViewCertificateToken
    extend ActiveSupport::Concern
    include Mongoid::Document
    # 6 months
    DEFAULT_TOKEN_VALIDITY_PERIOD = 183

    included do
      field :view_certificate_token, type: String
      field :view_certificate_token_created_at, type: DateTime
    end

    def generate_view_certificate_token
      self.view_certificate_token_created_at = Time.now
      self.view_certificate_token = SecureRandom.uuid
      save!

      view_certificate_token
    end

    def view_certificate_token_valid?
      return false unless view_certificate_token.present? && view_certificate_token_created_at.present?

      view_certificate_token_expires_at >= Time.now
    end

    def view_certificate_token_expires_at
      @view_certificate_token_validity_period = ENV.fetch("WCRS_VIEW_CERTIFICATE_TOKEN_VALIDITY_PERIOD",
                                                          DEFAULT_TOKEN_VALIDITY_PERIOD).to_i
      view_certificate_token_created_at + @view_certificate_token_validity_period.days
    end
  end
end
