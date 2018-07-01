require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :contact_address_manual_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "contact_address_manual_form")
        end

        context "when the business is 'overseas'" do
          before(:each) { transient_registration.location = "overseas" }

          it "changes to :contact_name_form after the 'back' event" do
            expect(transient_registration).to transition_from(:contact_address_manual_form).to(:contact_email_form).on_event(:back)
          end
        end

        # context "when the business is not 'overseas'" do
        #   before(:each) { transient_registration.location = "england" }
        #
        #   it "changes to :contact_postcode_form after the 'back' event" do
        #     expect(transient_registration).to transition_from(:contact_address_manual_form).to(:contact_postcode_form).on_event(:back)
        #   end
        # end

        it "changes to :main_people_form after the 'next' event" do
          expect(transient_registration).to transition_from(:contact_address_manual_form).to(:check_your_answers_form).on_event(:next)
        end
      end
    end
  end
end
