# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditRegistration, type: :model do
    describe "#workflow_state" do
      it_behaves_like "a simple monodirectional transition",
                      previous_and_next_state: :edit_form,
                      current_state: :location_form,
                      factory: :edit_registration
    end
  end
end