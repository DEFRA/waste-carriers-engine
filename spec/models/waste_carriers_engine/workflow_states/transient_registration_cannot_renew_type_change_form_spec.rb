require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :cannot_renew_type_change_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "cannot_renew_type_change_form")
        end

        it "changes to :business_type_form after the 'back' event" do
          expect(transient_registration).to transition_from(:cannot_renew_type_change_form).to(:business_type_form).on_event(:back)
        end

        it "does not respond to the 'next' event" do
          expect(transient_registration).to_not allow_event :next
        end
      end
    end
  end
end
