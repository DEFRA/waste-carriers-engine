require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :tier_check_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "tier_check_form")
        end

        it "transitions to :business_type_form after the 'back' event" do
          expect(transient_registration).to transition_from(:tier_check_form).to(:business_type_form).on_event(:back)
        end

        context "when the business is overseas" do
          before(:each) { transient_registration.location = "overseas" }

          it "transitions to :location_form after the 'back' event" do
            expect(transient_registration).to transition_from(:tier_check_form).to(:location_form).on_event(:back)
          end
        end

        context "when temp_tier_check is yes" do
          before(:each) { transient_registration.temp_tier_check = "yes" }

          it "transitions to :other_businesses_form after the 'next' event" do
            expect(transient_registration).to transition_from(:tier_check_form).to(:other_businesses_form).on_event(:next)
          end
        end

        context "when temp_tier_check is no" do
          before(:each) { transient_registration.temp_tier_check = "no" }

          it "transitions to :cbd_type_form after the 'next' event" do
            expect(transient_registration).to transition_from(:tier_check_form).to(:cbd_type_form).on_event(:next)
          end
        end
      end
    end
  end
end
