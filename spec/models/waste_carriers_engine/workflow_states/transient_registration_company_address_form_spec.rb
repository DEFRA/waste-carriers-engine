# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    describe "#workflow_state" do
      context "when a RenewingRegistration's state is :company_address_form" do
        let(:transient_registration) do
          create(:renewing_registration,
                 :has_required_data,
                 workflow_state: "company_address_form")
        end

        it "changes to :company_postcode_form after the 'back' event" do
          expect(transient_registration).to transition_from(:company_address_form).to(:company_postcode_form).on_event(:back)
        end

        it "changes to :main_people_form after the 'next' event" do
          expect(transient_registration).to transition_from(:company_address_form).to(:main_people_form).on_event(:next)
        end

        it "changes to :company_address_manual_form after the 'skip_to_manual_address' event" do
          expect(transient_registration).to transition_from(:company_address_form).to(:company_address_manual_form).on_event(:skip_to_manual_address)
        end
      end
    end
  end
end
