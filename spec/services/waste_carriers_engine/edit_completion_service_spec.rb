# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditCompletionService do
    let(:registration) { double(:edit_registration) }
    let(:edit_registration) do
      double(:edit_registration,
             registration: registration)
    end
    let(:service) { described_class.run(edit_registration: edit_registration) }

    describe ".run" do
      context "when given an edit_registration" do
        it "returns the registration" do
          expect(service).to eq(registration)
        end
      end
    end
  end
end
