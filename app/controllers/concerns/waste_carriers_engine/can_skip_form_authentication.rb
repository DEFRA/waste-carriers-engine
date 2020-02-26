# frozen_string_literal: true

module WasteCarriersEngine
  module CanSkipFormAuthentication
    extend ActiveSupport::Concern

    included do
      skip_before_filter :authenticate_user!

      def setup_checks_pass?
        # Do nothing. We don't run validations in publicly accessed forms

        true
      end
    end
  end
end
