# frozen_string_literal: true

module WasteCarriersEngine
  class CheckYourTierForm < BaseForm
    delegate :temp_check_your_tier, to: :transient_registration

    validates :temp_check_your_tier, inclusion: { in: %w[lower upper unknown] }
  end
end
