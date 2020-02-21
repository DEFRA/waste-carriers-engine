# frozen_string_literal: true

module WasteCarriersEngine
  class EditCompletionService < BaseService
    def run(edit_registration:)
      @edit_registration = edit_registration
      @registration = @edit_registration.registration

      delete_transient_registration
    end

    private

    def delete_transient_registration
      @edit_registration.delete
    end
  end
end
