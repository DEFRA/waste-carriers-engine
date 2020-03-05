# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    describe "#workflow_state" do
      it_behaves_like "a postcode transition",
                      previous_state: :company_name_form,
                      address_type: "company",
                      factory: :new_registration

      context ":company_postcode_form state transitions" do
        context "on skip_to_manual_address" do
          subject { build(:new_registration, workflow_state: "company_postcode_form") }

          it "transitions to :company_address_manual_form" do
            subject.skip_to_manual_address!

            expect(subject.workflow_state).to eq("company_address_manual_form")
          end
        end
      end
    end
  end
end
