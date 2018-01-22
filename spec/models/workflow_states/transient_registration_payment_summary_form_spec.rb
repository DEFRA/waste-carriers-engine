require "rails_helper"

RSpec.describe TransientRegistration, type: :model do
  describe "#workflow_state" do
    context "when a TransientRegistration's state is :payment_summary_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "payment_summary_form")
      end

      it "changes to :declaration_form after the 'back' event" do
        expect(transient_registration).to transition_from(:payment_summary_form).to(:declaration_form).on_event(:back)
      end

      it "changes to :worldpay_form after the 'next' event" do
        expect(transient_registration).to transition_from(:payment_summary_form).to(:worldpay_form).on_event(:next)
      end
    end
  end
end
