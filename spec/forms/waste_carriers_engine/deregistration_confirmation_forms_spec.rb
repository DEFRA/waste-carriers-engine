# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe DeregistrationConfirmationForm do
    describe "#submit" do
      let(:deregistration_confirmation_form) { build(:deregistration_confirmation_form) }

      it "submits" do
        expect(deregistration_confirmation_form.submit).to be true
      end
    end
  end
end
