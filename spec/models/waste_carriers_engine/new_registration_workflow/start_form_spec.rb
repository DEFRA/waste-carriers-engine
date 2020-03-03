# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, start_option: start_option) }

    describe "#workflow_state" do
      context ":start_form state transitions" do
        context "on next" do
          context "when the start_option is `renew`" do
            let(:start_option) { WasteCarriersEngine::StartForm::RENEW }

            include_examples "can transition next to", next_state: "renew_registration_form"
          end

          context "when the start_option is `new`" do
            let(:start_option) { WasteCarriersEngine::StartForm::NEW }

            include_examples "can transition next to", next_state: "location_form"
          end
        end
      end
    end
  end
end
