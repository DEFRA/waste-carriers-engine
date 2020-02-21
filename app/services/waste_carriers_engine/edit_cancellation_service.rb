# frozen_string_literal: true

module WasteCarriersEngine
  class EditCancellationService < BaseService
    def run(edit_registration:)
      edit_registration.delete
    end
  end
end
