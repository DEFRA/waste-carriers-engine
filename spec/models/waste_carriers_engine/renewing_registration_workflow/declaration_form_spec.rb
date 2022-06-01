# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            workflow_state: "declaration_form")
    end

    describe "#workflow_state" do
      context ":declaration_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "cards_form"
        end
      end
    end
  end
end
