# frozen_string_literal: true

module WasteCarriersEngine
  class EditCompletionService < BaseService
    def run(edit_registration:)
      @edit_registration = edit_registration
    end
  end
end
