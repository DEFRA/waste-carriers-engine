# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditCompletionService do
    let(:registration) { double(:edit_registration) }
    let(:edit_registration) do
      double(:edit_registration,
             registration: registration)
    end

    describe ".run" do
      context "when given an edit_registration" do
        it "deletes the edit_registration" do
          # Deletes transient registration
          expect(edit_registration).to receive(:delete)

          described_class.run(edit_registration: edit_registration)
        end
      end
    end
  end
end
