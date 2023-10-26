# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe MustRegisterInNorthernIrelandForm do
    describe "#workflow_state" do
      it_behaves_like "a fixed final state", current_state: :must_register_in_northern_ireland_form, factory: :new_registration
    end
  end
end
