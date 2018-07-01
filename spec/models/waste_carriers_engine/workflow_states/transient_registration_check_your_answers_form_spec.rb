require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :check_your_answers_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "check_your_answers_form")
        end

        it "changes to :contact_address_form after the 'back' event" do
          expect(transient_registration).to transition_from(:check_your_answers_form).to(:contact_address_form).on_event(:back)
        end

        it "changes to :declaration_form after the 'next' event" do
          expect(transient_registration).to transition_from(:check_your_answers_form).to(:declaration_form).on_event(:next)
        end
      end
    end
  end
end
