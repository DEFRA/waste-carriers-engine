# frozen_string_literal: true

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
        expect(past_registration.business_name).to eq(registration.business_name)
      end

      it "copies nested objects from the registration" do
        expect(past_registration.registered_address).to eq(registration.registered_address)
      end

      context "if :edit is given as an argument" do
        let(:past_registration) { PastRegistration.build_past_registration(registration, :edit) }

        it "sets the cause to 'edit'" do
          expect(past_registration.cause).to eq("edit")
        end
      end

      context "if there is already a past_registration with the same expiry date" do
        before do
          PastRegistration.build_past_registration(registration, :edit)
        end

        context "if the new version is a renewal" do
          context "if the past registration is a renewal" do
            before do
              PastRegistration.build_past_registration(registration)
            end

            it "returns nil and does not create a new past_registration" do
              past_registration_count = registration.past_registrations.count

              expect(past_registration).to eq(nil)

              expect(registration.reload.past_registrations.count).to eq(past_registration_count)
            end
          end

          context "if the past registration is not a renewal" do
            it "does create a new past_registration" do
              past_registration_count = registration.past_registrations.count
              past_registration
              expect(registration.reload.past_registrations.count).to eq(past_registration_count + 1)
            end
          end
        end

        context "if the new version is an edit" do
          let(:past_registration) { PastRegistration.build_past_registration(registration, :edit) }

          it "does create a new past_registration" do
            past_registration_count = registration.past_registrations.count
            past_registration
            expect(registration.reload.past_registrations.count).to eq(past_registration_count + 1)
          end
        end
      end
    end
  end
end
