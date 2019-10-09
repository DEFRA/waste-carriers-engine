# frozen_string_literal: true

module WasteCarriersEngine
  class ContactPhoneForm < BaseForm
    delegate :phone_number, to: :transient_registration

    validates :phone_number, "defra_ruby/validators/phone_number": true
  end
end
