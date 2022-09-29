# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditFormPresenter do
    subject(:presenter) { described_class.new(form, view) }

    let(:form) { double(:form, transient_registration: transient_registration) }

    describe "#receipt_email" do
      context "when the field does not exist" do
        let(:transient_registration) { double(:transient_registration) }

        it "returns nothing" do
          allow(transient_registration).to receive(:receipt_email)

          expect(presenter.receipt_email).to be_nil
        end
      end

      context "when the field exists" do
        let(:transient_registration) { double(:transient_registration, receipt_email: receipt_email) }
        let(:receipt_email) { "foo@example.com" }

        it "returns the value in receipt email" do
          expect(presenter.receipt_email).to eq(receipt_email)
        end
      end
    end
  end
end
