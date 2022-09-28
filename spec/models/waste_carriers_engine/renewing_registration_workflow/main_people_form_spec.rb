# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            workflow_state: "main_people_form")
    end

    describe "#workflow_state" do
      context "with :main_people_form state transitions" do
        context "with :next transition" do
          include_examples "has next transition", next_state: "use_trading_name_form"
        end
      end
    end
  end
end
