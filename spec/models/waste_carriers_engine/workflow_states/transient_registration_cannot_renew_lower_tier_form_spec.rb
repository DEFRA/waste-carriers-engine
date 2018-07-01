require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :cannot_renew_lower_tier_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "cannot_renew_lower_tier_form")
        end

        context "when the tier change is due to the business type" do
          before(:each) { transient_registration.business_type = "charity" }

          it "changes to :business_type_form after the 'back' event" do
            expect(transient_registration).to transition_from(:cannot_renew_lower_tier_form).to(:business_type_form).on_event(:back)
          end
        end

        context "when the tier change is because the business only deals with certain waste types" do
          before(:each) do
            transient_registration.other_businesses = true
            transient_registration.is_main_service = true
            transient_registration.only_amf = true
          end

          it "changes to :waste_types_form after the 'back' event" do
            expect(transient_registration).to transition_from(:cannot_renew_lower_tier_form).to(:waste_types_form).on_event(:back)
          end
        end

        context "when the tier change is because the business doesn't deal with construction waste" do
          before(:each) do
            transient_registration.other_businesses = false
            transient_registration.construction_waste = false
          end

          it "changes to :construction_demolition_form after the 'back' event" do
            expect(transient_registration).to transition_from(:cannot_renew_lower_tier_form).to(:construction_demolition_form).on_event(:back)
          end
        end

        it "does not respond to the 'next' event" do
          expect(transient_registration).to_not allow_event :next
        end
      end
    end
  end
end
