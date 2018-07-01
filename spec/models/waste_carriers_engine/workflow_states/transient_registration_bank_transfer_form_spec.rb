require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :bank_transfer_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "bank_transfer_form")
        end

        it "changes to :payment_summary_form after the 'back' event" do
          expect(transient_registration).to transition_from(:bank_transfer_form).to(:payment_summary_form).on_event(:back)
        end

        it "changes to :renewal_received_form after the 'next' event" do
          expect(transient_registration).to transition_from(:bank_transfer_form).to(:renewal_received_form).on_event(:next)
        end
      end
    end
  end
end
