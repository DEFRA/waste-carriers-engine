require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :service_provided_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "service_provided_form")
        end

        it "transitions to :other_businesses_form after the 'back' event" do
          expect(transient_registration).to transition_from(:service_provided_form).to(:other_businesses_form).on_event(:back)
        end

        context "when the business only carries waste it produces" do
          before(:each) { transient_registration.is_main_service = "no" }

          it "transitions to :construction_demolition_form after the 'next' event" do
            expect(transient_registration).to transition_from(:service_provided_form).to(:construction_demolition_form).on_event(:next)
          end
        end

        context "when the business carries waste produced by others" do
          before(:each) { transient_registration.is_main_service = "yes" }

          it "transitions to :waste_types_form after the 'next' event" do
            expect(transient_registration).to transition_from(:service_provided_form).to(:waste_types_form).on_event(:next)
          end
        end
      end
    end
  end
end
