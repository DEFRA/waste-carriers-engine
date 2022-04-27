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
    let(:declared_convictions) {}

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

        context "on back" do
          context "when the registered address was manually entered" do
            let(:registered_address) { build(:address, :registered, :manual_foreign) }
            subject { build(:renewing_registration, workflow_state: "declare_convictions_form", registered_address: registered_address) }

            include_examples "has back transition", previous_state: "company_address_manual_form"
          end

          include_examples "has back transition", previous_state: "company_address_form"
        end
      end
    end
  end
end
