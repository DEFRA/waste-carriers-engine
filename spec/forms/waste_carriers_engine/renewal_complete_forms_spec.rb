# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewalCompleteForm do
    it_behaves_like "a fixed final state",
                    current_state: :renewal_complete_form,
                    factory: :renewing_registration
  end
end
