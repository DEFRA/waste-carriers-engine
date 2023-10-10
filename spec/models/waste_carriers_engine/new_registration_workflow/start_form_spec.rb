# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject(:new_registration) { build(:new_registration, temp_start_option: temp_start_option) }

    describe "#workflow_state" do
      context "with :start_form state transitions" do
        context "with :next transition" do
          context "when the temp_start_option is `renew`" do
            let(:temp_start_option) { WasteCarriersEngine::StartForm::RENEW }

            include_examples "has next transition", next_state: "renewal_stop_form"
          end

          context "when the temp_start_option is `new`" do
            let(:temp_start_option) { WasteCarriersEngine::StartForm::NEW }

            include_examples "has next transition", next_state: "location_form"
          end
        end
      end
    end
  end
end
