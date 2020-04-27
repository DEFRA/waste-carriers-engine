# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration do
    it_behaves_like "an address lookup transition",
                    next_state_if_not_skipping_to_manual: :check_your_answers_form,
                    address_type: "contact",
                    factory: :renewing_registration
  end
end
