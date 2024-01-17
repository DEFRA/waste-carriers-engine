# frozen_string_literal: true

module WasteCarriersEngine
  module TokenExpiration
    extend ActiveSupport::Concern

    class_methods do
      def has_token_with_expiration(token_field:, timestamp_field:, default_period:, env_variable:)
        define_method("generate_#{token_field}") do
          write_attribute(timestamp_field, Time.zone.now)
          write_attribute(token_field, SecureRandom.uuid)
          save!

          send(token_field)
        end

        define_method("#{token_field}_valid?") do
          token = send(token_field)
          timestamp = send(timestamp_field)
          return false unless token.present? && timestamp.present?

          token_expires_at = timestamp + ENV.fetch(env_variable, default_period).to_i.days
          token_expires_at >= Time.zone.now
        end
      end
    end
  end
end
