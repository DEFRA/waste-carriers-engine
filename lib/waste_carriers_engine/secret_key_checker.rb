# frozen_string_literal: true

module WasteCarriersEngine

  class SecretKeyChecker

    attr_reader :secret_key

    def initialize(secret_key_base)
      @secret_key = secret_key_base
    end

    def abort_if_invalid
      return if valid?

      abort("Aborting! You have not set an env var for SECRET_KEY or you have used the production default.")
    end

    def valid?
      return false if @secret_key.blank?
      return false if @secret_key == "iamonlyherefordeviseduringassetcompilation"

      true
    end
  end

end
