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

      context "when the location is 'england'" do
        before(:each) { transient_registration.location = "england" }

        it "changes to :business_type_form after the 'next' event" do
          expect(transient_registration).to transition_from(:location_form).to(:business_type_form).on_event(:next)
        end
      end

      context "when the location is 'northern_ireland'" do
        before(:each) { transient_registration.location = "northern_ireland" }

        it "changes to :register_in_northern_ireland_form after the 'next' event" do
          expect(transient_registration).to transition_from(:location_form).to(:register_in_northern_ireland_form).on_event(:next)
        end
      end

      context "when the location is 'scotland'" do
        before(:each) { transient_registration.location = "scotland" }

        it "changes to :register_in_scotland_form after the 'next' event" do
          expect(transient_registration).to transition_from(:location_form).to(:register_in_scotland_form).on_event(:next)
        end
      end

      context "when the location is 'wales'" do
        before(:each) { transient_registration.location = "wales" }

        it "changes to :register_in_wales_form after the 'next' event" do
          expect(transient_registration).to transition_from(:location_form).to(:register_in_wales_form).on_event(:next)
        end
      end

      context "when the location is 'overseas'" do
        before(:each) { transient_registration.location = "overseas" }

        it "changes to :other_businesses_form after the 'next' event" do
          expect(transient_registration).to transition_from(:location_form).to(:other_businesses_form).on_event(:next)
        end
      end
    end
  end
end
