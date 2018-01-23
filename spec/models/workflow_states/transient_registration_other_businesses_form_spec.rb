require "rails_helper"

RSpec.describe TransientRegistration, type: :model do
  describe "#workflow_state" do
    context "when a TransientRegistration's state is :other_businesses_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "other_businesses_form")
      end

      it "transitions to :business_type_form after the 'back' event" do
        expect(transient_registration).to transition_from(:other_businesses_form).to(:business_type_form).on_event(:back)
      end

      context "when the business does not carry waste for other businesses or households" do
        before(:each) { transient_registration.other_businesses = false }

        it "transitions to :construction_demolition_form after the 'next' event" do
          expect(transient_registration).to transition_from(:other_businesses_form).to(:construction_demolition_form).on_event(:next)
        end
      end

      context "when the business does carry waste for other businesses or households" do
        before(:each) { transient_registration.other_businesses = true }

        it "transitions to :service_provided_form after the 'next' event" do
          expect(transient_registration).to transition_from(:other_businesses_form).to(:service_provided_form).on_event(:next)
        end
      end
    end
  end
end
