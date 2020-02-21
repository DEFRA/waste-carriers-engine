# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditCancellationService do
    describe "run" do
      let(:edit_registration) { double(:edit_registration) }

      it "deletes the edit_registration" do
        expect(edit_registration).to receive(:delete)

        described_class.run(edit_registration: edit_registration)
      end
    end
  end
end
