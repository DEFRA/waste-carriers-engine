# frozen_string_literal: true

module WasteCarriersEngine
  module CanGenerateAndValidateToken
    extend ActiveSupport::Concern
    include Mongoid::Document

    def generate_token(field, timestamp_field)
      self[timestamp_field] = Time.zone.now
      self[field] = SecureRandom.uuid
      save!

      self[field]
    end

    def token_valid?(field, timestamp_field, validity_period)
      token = self[field]
      timestamp = self[timestamp_field]
      return false unless token.present? && timestamp.present?

      timestamp + validity_period.days >= Time.zone.now
    end
  end
end
