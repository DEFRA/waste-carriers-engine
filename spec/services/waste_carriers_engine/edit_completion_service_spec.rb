# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditCompletionService do
    let(:edit_registration) { double(:edit_registration) }
    let(:service) { described_class.run(edit_registration: edit_registration) }

    describe ".run" do
      context "when given an edit_registration" do
        it "returns the edit_registration" do
          expect(service).to eq(edit_registration)
        end
      end
    end
  end
end
