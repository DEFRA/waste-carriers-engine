# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewalStopForm do
    describe "#workflow_state" do
      it_behaves_like "a fixed final state",
                      current_state: :renewal_stop_form,
                      factory: :renewing_registration
    end
  end
end
