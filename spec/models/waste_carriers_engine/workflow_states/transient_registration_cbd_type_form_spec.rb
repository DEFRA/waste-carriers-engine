require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :cbd_type" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "cbd_type_form")
        end

        context "when temp_tier_check is false" do
          before(:each) { transient_registration.temp_tier_check = false }

          it "transitions to :tier_check_form after the 'back' event" do
            expect(transient_registration).to transition_from(:cbd_type_form).to(:tier_check_form).on_event(:back)
          end
        end

        context "when temp_tier_check is true" do
          before(:each) { transient_registration.temp_tier_check = true }

          context "when the business doesn't carry waste for other businesses or households" do
            before(:each) { transient_registration.other_businesses = false }

            it "changes to :construction_demolition_form after the 'back' event" do
              expect(transient_registration).to transition_from(:cbd_type_form).to(:construction_demolition_form).on_event(:back)
            end
          end

          context "when the business carries waste produced by its customers" do
            before(:each) { transient_registration.is_main_service = true }

            it "changes to :waste_types_form after the 'back' event" do
              expect(transient_registration).to transition_from(:cbd_type_form).to(:waste_types_form).on_event(:back)
            end
          end

          context "when the business carries carries waste for other businesses but produces that waste" do
            before(:each) do
              transient_registration.other_businesses = true
              transient_registration.is_main_service = false
            end

            it "changes to :construction_demolition_form after the 'back' event" do
              expect(transient_registration).to transition_from(:cbd_type_form).to(:construction_demolition_form).on_event(:back)
            end
          end
        end

        it "changes to :renewal_information_form after the 'next' event" do
          expect(transient_registration).to transition_from(:cbd_type_form).to(:renewal_information_form).on_event(:next)
        end
      end
    end
  end
end
