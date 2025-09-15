# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    let(:business_type) { "limitedCompany" }

    subject { build(:new_registration, business_type: business_type, workflow_state: "main_people_form") }

    describe "#workflow_state" do
      context "with :main_people_form state transitions" do
        context "with :next transition" do
          it_behaves_like "has next transition", next_state: "use_trading_name_form"
        end
      end
    end
  end
end
