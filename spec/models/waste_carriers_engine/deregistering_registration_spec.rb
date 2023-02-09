# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe DeregisteringRegistration do
    subject(:deregistering_registration) { build(:deregistering_registration) }

    describe "workflow_state" do

      context "when a DeregisteringRegistration is created" do
        it "has the state :deregistration_confirmation_form" do
          expect(deregistering_registration).to have_state(:deregistration_confirmation_form)
        end
      end
    end

    describe "#can_be_deregistered?" do

      context "when the registration is not active" do
        let(:deregistering_registration) { build(:deregistering_registration, metadata_status: "INACTIVE") }

        it "returns false" do
          expect(deregistering_registration.can_be_deregistered?).to be false
        end
      end

      context "when the registration is active" do
        let(:deregistering_registration) { build(:deregistering_registration, metadata_status: "ACTIVE") }

        it "returns true" do
          expect(deregistering_registration.can_be_deregistered?).to be true
        end
      end

      # Self-serve deregistration is currently available only for lower-tier registrations
      context "when the registration is upper tier" do
        let(:deregistering_registration) { build(:deregistering_registration, tier: "UPPER") }

        it "returns false" do
          expect(deregistering_registration.can_be_deregistered?).to be false
        end
      end

      context "when the registration is lower tier" do
        let(:deregistering_registration) { build(:deregistering_registration, tier: "LOWER") }

        it "returns true" do
          expect(deregistering_registration.can_be_deregistered?).to be true
        end
      end
    end
  end
end
