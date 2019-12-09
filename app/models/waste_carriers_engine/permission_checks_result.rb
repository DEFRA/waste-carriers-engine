# frozen_string_literal: true

module WasteCarriersEngine
  class PermissionChecksResult
    attr_reader :error_state

    def initialize
      @pass = false
      @error_state = nil
    end

    def pass!
      @pass = true
    end

    def pass?
      @pass
    end

    def needs_permissions!
      @error_state = "permission"
    end

    def unrenewable!
      @error_state = "unrenewable"
    end

    def invalid!
      @error_state = "invalid"
    end
  end
end
