require "rails_helper"

RSpec.describe TransientRegistration, type: :model do
  describe "#workflow_state" do
    context "when a TransientRegistration's state is :location_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "location_form")
      end

      it "changes to :renewal_start_form after the 'back' event" do
        expect(transient_registration).to transition_from(:location_form).to(:renewal_start_form).on_event(:back)
      end

      it "changes to :business_type_form after the 'next' event" do
        expect(transient_registration).to transition_from(:location_form).to(:business_type_form).on_event(:next)
      end
    end
  end
end
