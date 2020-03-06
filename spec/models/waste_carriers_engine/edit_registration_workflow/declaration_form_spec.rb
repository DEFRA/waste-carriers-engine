# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditRegistration, type: :model do
    describe "#workflow_state" do
      context "when an EditRegistration's state is :declaration_form" do
        let(:transient_registration) do
          create(:edit_registration,
                 workflow_state: "declaration_form")
        end

        context "when the registration type has not changed" do
          it "changes to :edit_complete_form after the 'next' event" do
            expect(transient_registration).to transition_from(:declaration_form).to(:edit_complete_form).on_event(:next)
          end
        end

        context "when the registration type has changed" do
          before(:each) { transient_registration.registration_type = "broker_dealer" }

          it "changes to :edit_payment_summary_form after the 'next' event" do
            expect(transient_registration).to transition_from(:declaration_form).to(:edit_payment_summary_form).on_event(:next)
          end
        end

        it "changes to :edit_form after the 'back' event" do
          expect(transient_registration).to transition_from(:declaration_form).to(:edit_form).on_event(:back)
        end
      end
    end
  end
end
