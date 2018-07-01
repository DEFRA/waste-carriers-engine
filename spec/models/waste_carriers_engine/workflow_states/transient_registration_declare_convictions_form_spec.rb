require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :declare_convictions_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "declare_convictions_form")
        end

        it "changes to :main_people_form after the 'back' event" do
          expect(transient_registration).to transition_from(:declare_convictions_form).to(:main_people_form).on_event(:back)
        end

        context "when declared_convictions is true" do
          before(:each) do
            transient_registration.declared_convictions = true
          end

          it "changes to :conviction_details_form after the 'next' event" do
            expect(transient_registration).to transition_from(:declare_convictions_form).to(:conviction_details_form).on_event(:next)
          end
        end

        context "when declared_convictions is false" do
          before(:each) do
            transient_registration.declared_convictions = false
          end

          it "changes to :contact_name_form after the 'next' event" do
            expect(transient_registration).to transition_from(:declare_convictions_form).to(:contact_name_form).on_event(:next)
          end
        end
      end
    end
  end
end
