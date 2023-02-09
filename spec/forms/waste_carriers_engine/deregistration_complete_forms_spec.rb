# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe DeregistrationCompleteForm do
    it_behaves_like "a fixed final state",
                    current_state: :deregistration_complete_form,
                    factory: :deregistering_registration
  end
end
