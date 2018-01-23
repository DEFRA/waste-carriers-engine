require "rails_helper"

RSpec.describe TransientRegistration, type: :model do
  describe "#workflow_state" do
    context "when a TransientRegistration's state is :registration_number_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "registration_number_form")
      end

      it "changes to :renewal_information_form after the 'back' event" do
        expect(transient_registration).to transition_from(:registration_number_form).to(:renewal_information_form).on_event(:back)
      end

      it "changes to :company_name_form after the 'next' event" do
        expect(transient_registration).to transition_from(:registration_number_form).to(:company_name_form).on_event(:next)
      end
    end
  end
end
