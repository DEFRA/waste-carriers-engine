# frozen_string_literal: true

module WasteCarriersEngine
  module UnsubmittableForm
    extend ActiveSupport::Concern

    included do
      # Override this method as user shouldn't be able to "submit" this page
      def create; end
    end
  end
end
