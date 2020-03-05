# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    it_behaves_like "an address lookup transition",
                    next_state_if_not_skipping_to_manual: :check_your_answers_form,
                    address_type: "contact",
                    factory: :new_registration

    subject { build(:new_registration, workflow_state: "contact_address_form") }

    describe "#workflow_state" do
      context ":contact_address_form state transitions" do
        context "on skip_to_manual_address" do
          it "transitions to :contact_address_manual_form" do
            subject.skip_to_manual_address!

            expect(subject.workflow_state).to eq("contact_address_manual_form")
          end
        end
      end
    end
  end
end
