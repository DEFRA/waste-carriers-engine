# frozen_string_literal: true

require "securerandom"

module WasteCarriersEngine
  # SecureTokenService generates a random base58 string of length 24.
  #
  # SecureRandom::base58 is used to generate the 24-character unique tokens, so
  # collisions are highly unlikely.
  #
  # The result will contain only alphanumeric characters except 0, O, I and l
  #
  #   p SecureRandom.base58 #=> "4kUgL2pdQMSCQtjE"
  #   p SecureRandom.base58(24) #=> "77TMHrHJFvFDwodq8w7Ev2m7"
  #
  # Copied almost verbatim from
  # https://github.com/robertomiranda/has_secure_token
  class SecureTokenService < BaseService
    BASE58_ALPHABET = ("0".."9").to_a + ("A".."Z").to_a + ("a".."z").to_a - %w[0 O I l]

    def run
      SecureRandom.random_bytes(24).unpack("C*").map do |byte|
        idx = byte % 64
        idx = SecureRandom.random_number(58) if idx >= 58
        BASE58_ALPHABET[idx]
      end.join
    end

  end
end
