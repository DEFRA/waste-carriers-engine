# frozen_string_literal: true

module WasteCarriersEngine
  class StartForm < BaseForm
    START_OPTIONS = [
      RENEW = "renew",
      NEW = "new"
    ].freeze

    delegate :start_option, to: :transient_registration

    validates :start_option, inclusion: { in: START_OPTIONS }
  end
end
