# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    describe "#workflow_state" do
      it_behaves_like "a manual address transition",
                      previous_state_if_overseas: :contact_address_reuse_form,
                      next_state: :check_your_answers_form,
                      address_type: "contact",
                      factory: :new_registration
    end
  end
end
