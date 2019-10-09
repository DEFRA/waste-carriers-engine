# frozen_string_literal: true

module WasteCarriersEngine
  class BusinessTypeForm < BaseForm
    delegate :business_type, to: :transient_registration

    validates :business_type, "defra_ruby/validators/business_type": { allow_overseas: true }
  end
end
