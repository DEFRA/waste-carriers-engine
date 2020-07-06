# frozen_string_literal: true

module WasteCarriersEngine
  class ReceiptEmailForm < ::WasteCarriersEngine::BaseForm
    delegate :receipt_email, to: :transient_registration

    validates :receipt_email, "defra_ruby/validators/email": true
  end
end
