require "rails_helper"

module WasteCarriersEngine
  RSpec.describe PastRegistration, type: :model do
    let(:registration) { create(:registration, :has_required_data, :expires_soon) }

    describe "build_past_registration" do
      let(:past_registration) { PastRegistration.build_past_registration(registration) }

      it "creates a new past_registration" do
        past_registration_count = registration.past_registrations.count
        past_registration
        expect(registration.reload.past_registrations.count).to eq(past_registration_count + 1)
      end

      it "belongs to the registration" do
        expect(past_registration.registration).to eq(registration)
      end

      it "copies attributes from the registration" do
        expect(past_registration.company_name).to eq(registration.company_name)
      end

      it "copies nested objects from the registration" do
        expect(past_registration.registered_address).to eq(registration.registered_address)
      end

      context "if there is already a past_registration for this version of the registration" do
        before do
          PastRegistration.build_past_registration(registration)
        end

        it "returns nil" do
          expect(past_registration).to eq(nil)
        end

        it "does not create a new past_registration" do
          past_registration_count = registration.past_registrations.count
          past_registration
          expect(registration.reload.past_registrations.count).to eq(past_registration_count)
        end
      end
    end
  end
end
