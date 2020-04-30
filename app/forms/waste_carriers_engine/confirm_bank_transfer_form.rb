# frozen_string_literal: true

module WasteCarriersEngine
  class ConfirmBankTransferForm < BaseForm
    def self.can_navigate_flexibly?
      false
    end
  end
end
