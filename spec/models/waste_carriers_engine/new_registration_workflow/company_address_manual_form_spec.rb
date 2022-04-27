# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    describe "#workflow_state" do
      context "when the registration is upper tier" do
        let(:tier) { WasteCarriersEngine::Registration::UPPER_TIER }

        it_behaves_like "a manual address transition",
                        previous_state_if_overseas: :company_name_form,
                        next_state: :declare_convictions_form,
                        address_type: "company",
                        factory: :new_registration
      end

      context "when the registration is lower tier" do
        let(:tier) { WasteCarriersEngine::Registration::LOWER_TIER }

        it_behaves_like "a manual address transition",
                        previous_state_if_overseas: :company_name_form,
                        next_state: :contact_name_form,
                        address_type: "company",
                        factory: :new_registration
      end

      describe "#workflow_state" do
        context ":company_address_manual_form state transitions" do
          context "on next" do
            context "when the registration is a lower tier" do
              subject { build(:new_registration, :lower, workflow_state: "company_address_manual_form") }

              include_examples "has next transition", next_state: "contact_name_form"
            end
          end
        end
      end
    end
  end
end
