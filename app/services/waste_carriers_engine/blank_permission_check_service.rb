# frozen_string_literal: true

module WasteCarriersEngine
  class BlankPermissionCheckService < BaseRegistrationPermissionChecksService

    private

    def all_checks_pass?
      true
    end
  end
end
