# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe LastDayOfGraceWindowService do
    describe "run" do
      let(:registration) { instance_double(Registration) }
      let(:expiry_date) { Date.new(2020, 12, 1) }
      let(:expected_date_for_grace_window) { (expiry_date + 5.days) - 1.day }
      let(:service) { described_class.run(registration: registration) }

      before do
        allow(Rails.configuration).to receive(:expires_after).and_return(3)
        allow(Rails.configuration).to receive(:grace_window).and_return(5)

        allow(ExpiryDateService).to receive(:run).with(registration: registration).and_return(expiry_date)
      end

      it "returns the standard grace window date" do
        expect(service).to eq(expected_date_for_grace_window)
      end
    end
  end
end
