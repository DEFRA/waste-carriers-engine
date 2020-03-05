# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "contact_name_form") }

    describe "#workflow_state" do
      context ":contact_name_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "contact_phone_form"
        end

        context "on back" do
          context "When the user has convictions to declare" do
            subject { build(:new_registration, workflow_state: "contact_name_form", declared_convictions: "yes") }

            include_examples "has back transition", previous_state: "conviction_details_form"
          end

          include_examples "has back transition", previous_state: "declare_convictions_form"
        end
      end
    end
  end
end
