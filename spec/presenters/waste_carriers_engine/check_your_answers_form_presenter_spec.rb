# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CheckYourAnswersFormPresenter do
    subject { described_class.new(object) }

    describe "#new_registration?" do
      context "when the object is of type NewRegistration" do
        let(:object) { WasteCarriersEngine::NewRegistration.new }

        it "returns true" do
          expect(subject).to be_a_new_registration
        end
      end

      context "when the object is not of type NewRegistration" do
        let(:object) { double(:object) }

        it "returns false" do
          expect(subject).to_not be_a_new_registration
        end
      end
    end

    describe "#renewal?" do
      context "when the object is of type RenewingRegistration" do
        let(:object) { WasteCarriersEngine::RenewingRegistration.new }

        it "returns true" do
          expect(subject).to be_a_renewal
        end
      end

      context "when the object is not of type RenewingRegistration" do
        let(:object) { double(:object) }

        it "returns false" do
          expect(subject).to_not be_a_renewal
        end
      end
    end
  end
end
