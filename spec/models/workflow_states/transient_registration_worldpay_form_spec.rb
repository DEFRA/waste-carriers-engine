require "rails_helper"

RSpec.describe TransientRegistration, type: :model do
  describe "#workflow_state" do
    context "when a TransientRegistration's state is :worldpay_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "worldpay_form")
      end

      it "changes to :payment_summary_form after the 'back' event" do
        expect(transient_registration).to transition_from(:worldpay_form).to(:payment_summary_form).on_event(:back)
      end

      context "when there are no convictions" do
        before(:each) { transient_registration.declared_convictions = false }

        it "changes to :renewal_complete_form after the 'next' event" do
          expect(transient_registration).to transition_from(:worldpay_form).to(:renewal_complete_form).on_event(:next)
        end
      end

      context "when there are convictions" do
        before(:each) { transient_registration.declared_convictions = true }

        it "changes to :renewal_received_form after the 'next' event" do
          expect(transient_registration).to transition_from(:worldpay_form).to(:renewal_received_form).on_event(:next)
        end
      end
    end
  end
end
