# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject(:new_registration) { build(:new_registration, temp_start_option: temp_start_option) }

    describe "#workflow_state" do
      context ":start_form state transitions" do
        context "on next" do
          context "when the temp_start_option is `renew`" do
            let(:temp_start_option) { WasteCarriersEngine::StartForm::RENEW }

            it "can transition from a :start_form state to a :renew_registration_form" do
              new_registration.next

              expect(new_registration.workflow_state).to eq("renew_registration_form")
            end
          end

          context "when the temp_start_option is `new`" do
            let(:temp_start_option) { WasteCarriersEngine::StartForm::NEW }

            it "can transition from a :start_form state to a :location_form" do
              new_registration.next

              expect(new_registration.workflow_state).to eq("location_form")
            end
          end
        end
      end
    end
  end
end
