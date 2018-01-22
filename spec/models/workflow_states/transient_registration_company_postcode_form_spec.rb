require "rails_helper"

RSpec.describe TransientRegistration, type: :model do
  describe "#workflow_state" do
    context "when a TransientRegistration's state is :company_postcode_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "company_postcode_form")
      end

      it "changes to :company_name_form after the 'back' event" do
        expect(transient_registration).to transition_from(:company_postcode_form).to(:company_name_form).on_event(:back)
      end

      it "changes to :company_address_form after the 'next' event" do
        expect(transient_registration).to transition_from(:company_postcode_form).to(:company_address_form).on_event(:next)
      end
    end
  end
end
