require "rails_helper"

RSpec.describe TransientRegistration, type: :model do
  describe "#workflow_state" do
    context "when a TransientRegistration's state is :key_people_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "key_people_form")
      end

      context "when the business type is not overseas" do
        before(:each) { transient_registration.business_type = "limitedCompany" }

        it "changes to :company_address_form after the 'back' event" do
          expect(transient_registration).to transition_from(:key_people_form).to(:company_address_form).on_event(:back)
        end
      end

      context "when the business type is overseas" do
        before(:each) { transient_registration.business_type = "overseas" }

        it "changes to :company_address_manual_form after the 'back' event" do
          expect(transient_registration).to transition_from(:key_people_form).to(:company_address_manual_form).on_event(:back)
        end
      end

      it "changes to :declare_convictions_form after the 'next' event" do
        expect(transient_registration).to transition_from(:key_people_form).to(:declare_convictions_form).on_event(:next)
      end
    end
  end
end
