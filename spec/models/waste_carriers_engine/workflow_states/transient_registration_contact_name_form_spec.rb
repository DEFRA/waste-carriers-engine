require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :contact_name_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "contact_name_form")
        end

        context "when declared_convictions is no" do
          before(:each) do
            transient_registration.declared_convictions = "no"
          end

          it "changes to :declare_convictions_form after the 'back' event" do
            expect(transient_registration).to transition_from(:contact_name_form).to(:declare_convictions_form).on_event(:back)
          end
        end

        context "when declared_convictions is yes" do
          before(:each) do
            transient_registration.declared_convictions = "yes"
          end

          it "changes to :conviction_details_form after the 'back' event" do
            expect(transient_registration).to transition_from(:contact_name_form).to(:conviction_details_form).on_event(:back)
          end
        end

        it "changes to :contact_phone_form after the 'next' event" do
          expect(transient_registration).to transition_from(:contact_name_form).to(:contact_phone_form).on_event(:next)
        end
      end
    end
  end
end
