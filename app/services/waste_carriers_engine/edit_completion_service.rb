# frozen_string_literal: true

module WasteCarriersEngine
  class EditCompletionService < BaseService
    def run(edit_registration:)
      @edit_registration = edit_registration
      @registration = @edit_registration.registration
    end
  end
end
