# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "declare_convictions_form") }

    describe "#workflow_state" do
      context "with :declare_convictions_form state transitions" do
        context "with :next transition" do
          context "when the users has convictions to declare" do
            subject { build(:new_registration, workflow_state: "declare_convictions_form", declared_convictions: "yes") }

            include_examples "has next transition", next_state: "conviction_details_form"
          end

          include_examples "has next transition", next_state: "contact_name_form"
        end
      end
    end
  end
end
