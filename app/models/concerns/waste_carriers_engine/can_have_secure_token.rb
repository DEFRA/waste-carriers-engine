# frozen_string_literal: true

module WasteCarriersEngine
  module CanHaveSecureToken
    extend ActiveSupport::Concern
    include Mongoid::Document

    included do
      field :token, type: String

      before_create :generate_unique_secure_token

      def generate_unique_secure_token
        self.token = SecureRandom.base64(24)
      end
    end
  end
end
