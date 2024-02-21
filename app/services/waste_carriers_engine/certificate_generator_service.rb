# frozen_string_literal: true

module WasteCarriersEngine
  class CertificateGeneratorService < BaseService
    def run(registration:, requester: nil, view: nil)
      @registration = registration
      @requester = requester
      @view = view

      init_presenter
    end

    private

    def init_presenter
      @init_presenter ||= CertificatePresenter.new(@registration, @view)
    end
  end
end
