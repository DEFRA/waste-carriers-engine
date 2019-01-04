# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedForm < BaseForm
    attr_accessor :contact_email, :pending_convictions_check, :pending_payment, :pending_worldpay_payment

    def initialize(transient_registration)
      super
      self.contact_email = @transient_registration.contact_email
      self.pending_convictions_check = @transient_registration.conviction_check_required?
      self.pending_payment = @transient_registration.pending_payment?
      self.pending_worldpay_payment = @transient_registration.pending_worldpay_payment?
    end

    # Override BaseForm method as users shouldn't be able to submit this form
    def submit; end
  end
end
