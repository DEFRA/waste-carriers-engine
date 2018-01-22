require "rails_helper"

RSpec.describe TransientRegistration, type: :model do
  describe "#workflow_state" do
    context "when a TransientRegistration's state is :construction_demolition_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "construction_demolition_form")
      end

      context "when the business does not carry waste for other businesses or households" do
        before(:each) { transient_registration.other_businesses = false }

        it "transitions to :service_provided_form after the 'back' event" do
          expect(transient_registration).to transition_from(:construction_demolition_form).to(:other_businesses_form).on_event(:back)
        end
      end

      context "when the business does carry waste for other businesses or households" do
        before(:each) { transient_registration.other_businesses = true }

        it "transitions to :service_provided_form after the 'back' event" do
          expect(transient_registration).to transition_from(:construction_demolition_form).to(:service_provided_form).on_event(:back)
        end
      end

      context "when the registration should change to lower tier" do
        before(:each) do
          transient_registration.other_businesses = true
          transient_registration.is_main_service = true
          transient_registration.only_amf = true
        end

        it "transitions to :cannot_renew_lower_tier_form after the 'next' event" do
          expect(transient_registration).to transition_from(:construction_demolition_form).to(:cannot_renew_lower_tier_form).on_event(:next)
        end
      end

      context "when the registration should stay upper tier" do
        before(:each) do
          transient_registration.other_businesses = true
          transient_registration.is_main_service = true
          transient_registration.only_amf = false
        end

        it "transitions to :cbd_type_form after the 'next' event" do
          expect(transient_registration).to transition_from(:construction_demolition_form).to(:cbd_type_form).on_event(:next)
        end
      end
    end
  end
end
