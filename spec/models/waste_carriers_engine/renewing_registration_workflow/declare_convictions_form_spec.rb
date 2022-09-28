# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            declared_convictions: declared_convictions,
            workflow_state: "declare_convictions_form")
    end
    let(:declared_convictions) { nil }

    describe "#workflow_state" do
      context ":declare_convictions_form state transitions" do
        context "on next" do

          context "when declared_convictions is yes" do
            let(:declared_convictions) { "yes" }

            include_examples "has next transition", next_state: "conviction_details_form"
          end

          context "when declared_convictions is no" do
            let(:declared_convictions) { "no" }

            include_examples "has next transition", next_state: "contact_name_form"
          end
        end
      end
    end
  end
end
