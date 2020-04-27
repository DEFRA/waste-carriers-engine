# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            addresses: addresses,
            workflow_state: "main_people_form")
    end
    let(:addresses) { [] }

    describe "#workflow_state" do
      context ":main_people_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "declare_convictions_form"
        end

        context "on back" do
          context "when the registered address was selected from OS Places" do
            let(:addresses) { [build(:address, :registered, :from_os_places)] }

            include_examples "has back transition", previous_state: "company_address_form"
          end

          context "when the registered address was entered manually" do
            let(:addresses) { [build(:address, :registered, :manual_uk)] }

            include_examples "has back transition", previous_state: "company_address_manual_form"
          end
        end
      end
    end
  end
end
