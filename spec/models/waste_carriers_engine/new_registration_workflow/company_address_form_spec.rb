# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    it_behaves_like "an address lookup transition",
                    next_state_if_not_skipping_to_manual: :main_people_form,
                    address_type: "company",
                    factory: :new_registration

    describe "#workflow_state" do
      context ":company_address_form state transitions" do
        context "on next" do
          context "when the registration is a lower tier" do
            subject { build(:new_registration, :lower, workflow_state: "company_address_form") }

            include_examples "has next transition", next_state: "contact_name_form"
          end
        end
      end
    end
  end
end
