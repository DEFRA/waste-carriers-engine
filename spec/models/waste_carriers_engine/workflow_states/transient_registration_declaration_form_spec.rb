require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :declaration_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "declaration_form")
        end

        it "changes to :check_your_answers_form after the 'back' event" do
          expect(transient_registration).to transition_from(:declaration_form).to(:check_your_answers_form).on_event(:back)
        end

        it "changes to :cards_form after the 'next' event" do
          expect(transient_registration).to transition_from(:declaration_form).to(:cards_form).on_event(:next)
        end
      end
    end
  end
end
