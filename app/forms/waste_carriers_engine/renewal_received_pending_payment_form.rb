# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedPendingPaymentForm < BaseForm
    include CannotSubmit

    delegate :pending_payment?, :pending_worldpay_payment?, to: :transient_registration

    def self.can_navigate_flexibly?
      false
    end
  end
end
