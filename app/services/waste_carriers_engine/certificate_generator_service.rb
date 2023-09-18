# frozen_string_literal: true

module WasteCarriersEngine
  class CertificateGeneratorService < BaseService
    def run(registration:, requester: nil, view: nil)
      @registration = registration
      @requester = requester
      @view = view

      increment_version_number
      init_presenter
    end

    private

    def increment_version_number
      @registration.increment_certificate_version(@requester)
    end

    def init_presenter
      @init_presenter ||= CertificatePresenter.new(@registration, @view)
    end
  end
end
