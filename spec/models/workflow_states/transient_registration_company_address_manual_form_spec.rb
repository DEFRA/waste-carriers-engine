require "rails_helper"

RSpec.describe TransientRegistration, type: :model do
  describe "#workflow_state" do
    context "when a TransientRegistration's state is :company_address_manual_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "company_address_manual_form")
      end

      context "when the business is 'overseas'" do
        before(:each) { transient_registration.location = "overseas" }

        it "changes to :company_name_form after the 'back' event" do
          expect(transient_registration).to transition_from(:company_address_manual_form).to(:company_name_form).on_event(:back)
        end
      end

      context "when the business is not 'overseas'" do
        before(:each) { transient_registration.location = "england" }

        it "changes to :company_postcode_form after the 'back' event" do
          expect(transient_registration).to transition_from(:company_address_manual_form).to(:company_postcode_form).on_event(:back)
        end
      end

      it "changes to :key_people_form after the 'next' event" do
        expect(transient_registration).to transition_from(:company_address_manual_form).to(:key_people_form).on_event(:next)
      end
    end
  end
end
