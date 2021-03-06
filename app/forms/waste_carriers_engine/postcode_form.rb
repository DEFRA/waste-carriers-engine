# frozen_string_literal: true

module WasteCarriersEngine
  class PostcodeForm < ::WasteCarriersEngine::BaseForm
    private

    def format_postcode(postcode)
      return unless postcode.present?

      postcode.upcase.strip
    end
  end
end
