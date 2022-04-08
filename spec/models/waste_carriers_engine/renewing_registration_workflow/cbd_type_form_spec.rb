# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            workflow_state: "cbd_type_form")
    end

    describe "#workflow_state" do
      context ":cbd_type_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "renewal_information_form"
        end

        context "on back" do
          context "when the registration is not overseas" do
            before { subject.location = "england" }

            include_examples "has back transition", previous_state: "business_type_form"
          end

          context "when the registration is overseas" do
            before { subject.location = "overseas" }

            include_examples "has back transition", previous_state: "location_form"
          end
        end
      end
    end
  end
end
