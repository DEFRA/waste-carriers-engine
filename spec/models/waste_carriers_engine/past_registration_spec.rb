# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe PastRegistration do
    let(:registration) { create(:registration, :has_required_data, :expires_soon) }

    describe "build_past_registration" do
      let(:past_registration) { described_class.build_past_registration(registration) }

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
        expect(past_registration.registered_address.attributes.except("_id"))
          .to eq(registration.registered_address.attributes.except("_id"))
      end

      context "with non-copyable attribute values" do
        # Non-copyable attributes include legacy attributes which may have values in the DB
        # but no accessors in the model, so we need to populate test values below the mongoid layer.
        before do
          WasteCarriersEngine::Registration.collection.update_one(
            { regIdentifier: registration.regIdentifier },
            { "$set": { accountEmail: "foo@example.com" } }
          )
          registration.reload
        end

        it "builds without error" do
          expect { described_class.build_past_registration(registration) }.not_to raise_error
        end
      end

      context "when :edit is given as an argument" do
        let(:past_registration) { described_class.build_past_registration(registration, :edit) }

        it "sets the cause to 'edit'" do
          expect(past_registration.cause).to eq("edit")
        end
      end

      context "when there is already a past_registration with the same expiry date" do
        before do
          described_class.build_past_registration(registration, :edit)
        end

        context "when the new version is a renewal" do
          context "when the past registration is a renewal" do
            before do
              described_class.build_past_registration(registration)
            end

            it "returns nil and does not create a new past_registration" do
              past_registration_count = registration.past_registrations.count

              expect(past_registration).to be_nil

              expect(registration.reload.past_registrations.count).to eq(past_registration_count)
            end
          end

          context "when the past registration is not a renewal" do
            it "does create a new past_registration" do
              past_registration_count = registration.past_registrations.count
              past_registration
              expect(registration.reload.past_registrations.count).to eq(past_registration_count + 1)
            end
          end
        end

        context "when the new version is an edit" do
          let(:past_registration) { described_class.build_past_registration(registration, :edit) }

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
