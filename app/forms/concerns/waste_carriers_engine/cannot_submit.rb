# frozen_string_literal: true

module WasteCarriersEngine
  module CannotSubmit
    extend ActiveSupport::Concern

    included do
      # Override BaseForm method as users shouldn't be able to submit this form
      def submit; end
    end
  end
end
