# frozen_string_literal: true

module WasteCarriersEngine
  class BankTransferForm < BaseForm
    delegate :total_to_pay, to: :transient_registration

    def self.can_navigate_flexibly?
      false
    end
  end
end
