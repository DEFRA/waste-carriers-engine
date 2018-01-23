require "rails_helper"

RSpec.describe TransientRegistration, type: :model do
  describe "#workflow_state" do
    context "when a TransientRegistration's state is :company_address_overseas_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "company_address_overseas_form")
      end

      it "changes to :company_name_form after the 'back' event" do
        expect(transient_registration).to transition_from(:company_address_overseas_form).to(:company_name_form).on_event(:back)
      end

      it "changes to :key_people_form after the 'next' event" do
        expect(transient_registration).to transition_from(:company_address_overseas_form).to(:key_people_form).on_event(:next)
      end
    end
  end
end
