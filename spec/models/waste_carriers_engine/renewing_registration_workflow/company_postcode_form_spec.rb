# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration do
    describe "#workflow_state" do

      context "when the registration is upper tier" do
        let(:tier) { WasteCarriersEngine::Registration::UPPER_TIER }

        it_behaves_like "a postcode transition",
                        previous_state: :main_people_form,
                        address_type: "company",
                        factory: :renewing_registration
      end

      context "when the registration is lower tier" do
        let(:tier) { WasteCarriersEngine::Registration::LOWER_TIER }

        it_behaves_like "a postcode transition",
                        previous_state: :company_name_form,
                        address_type: "company",
                        factory: :renewing_registration
      end
    end
  end
end
