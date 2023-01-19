# frozen_string_literal: true

require "rails_helper"

class DebugClass
  include WasteCarriersEngine::CanAddDebugLogging
end

module WasteCarriersEngine
  RSpec.describe CanAddDebugLogging do

    describe "#log_transient_registration_details" do

      let(:transient_registration) { create(:new_registration, :has_required_data) }

      subject(:log_details) { DebugClass.new.log_transient_registration_details("foo", transient_registration) }

      before do
        allow(Airbrake).to receive(:notify)
        allow(FeatureToggle).to receive(:active?).with(:additional_debug_logging).and_return true
      end

      it "logs an error" do
        log_details
        expect(Airbrake).to have_received(:notify)
      end

      context "with a nil transient_registration" do
        before { allow(transient_registration).to receive(:nil?).and_return(true) }

        it "logs an error" do
          log_details
          expect(Airbrake).to have_received(:notify)
        end
      end

      context "when the additional logging raises an exception" do
        before { allow(transient_registration).to receive(:metaData).and_raise(StandardError) }

        it "catches the exception and notifies Airbrake anyway" do
          log_details
          expect(Airbrake).to have_received(:notify)
        end
      end

      context "when the call to Airbrake fails" do
        before { allow(Airbrake).to receive(:notify).and_raise(StandardError) }

        it "completes without raising another exception" do
          expect { log_details }.not_to raise_error
        end
      end
    end
  end
end
