require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :contact_postcode_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "contact_postcode_form")
        end

        it "changes to :contact_email_form after the 'back' event" do
          expect(transient_registration).to transition_from(:contact_postcode_form).to(:contact_email_form).on_event(:back)
        end

        it "changes to :contact_address_form after the 'next' event" do
          expect(transient_registration).to transition_from(:contact_postcode_form).to(:contact_address_form).on_event(:next)
        end

        it "changes to :contact_address_manual_form after the 'skip_to_manual_address' event" do
          expect(transient_registration).to transition_from(:contact_postcode_form).to(:contact_address_manual_form).on_event(:skip_to_manual_address)
        end
      end
    end
  end
end
