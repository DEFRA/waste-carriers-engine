# frozen_string_literal: true

module WasteCarriersEngine
  class RegistrationCompletionService < BaseService
    def run(registration:)
      registration.metaData.date_activated = Time.current
      registration.metaData.activate!
    end
  end
end
