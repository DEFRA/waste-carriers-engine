# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NotifyCallbackJob do
    describe ".perform_later" do
      subject(:perform_later) { described_class.perform_later(callback_payload) }

      let(:callback_payload) { { "id" => "test-uuid", "status" => "delivered", "notification_type" => "email" } }

      it { expect { perform_later }.not_to raise_error }

      it { expect { perform_later }.to have_enqueued_job(described_class).exactly(:once) }
    end

    describe ".perform_now" do
      subject(:perform_now) { described_class.perform_now(callback_payload) }

      let(:callback_payload) { { "id" => "test-uuid", "status" => "delivered", "notification_type" => "email" } }
      let(:service_result) { { notification_id: "test-uuid", status: "delivered" } }

      before do
        allow(NotifyCallbackHandlerService).to receive(:run).and_return(service_result)
        allow(Rails.logger).to receive(:info)
      end

      it "calls NotifyCallbackHandlerService with the payload" do
        perform_now

        expect(NotifyCallbackHandlerService).to have_received(:run).with(callback_payload)
      end

      it "logs the result" do
        perform_now

        expect(Rails.logger).to have_received(:info).with(/notification_id: test-uuid, status: delivered/)
      end

      context "when the handler raises an error" do
        before do
          allow(NotifyCallbackHandlerService).to receive(:run).and_raise(StandardError.new("Test error"))
          allow(Airbrake).to receive(:notify)
          allow(Rails.logger).to receive(:error)
        end

        context "with a delivery receipt callback payload" do
          it "notifies Airbrake" do
            perform_now

            expect(Airbrake).to have_received(:notify).with(
              an_instance_of(StandardError),
              hash_including(notification_id: "test-uuid")
            )
          end

          it "logs the error" do
            perform_now

            expect(Rails.logger).to have_received(:error).with(/Error running NotifyCallbackJob/)
          end
        end

        context "with a returned letter callback payload" do
          let(:callback_payload) { { "notification_id" => "letter-uuid", "template_name" => "confirmation" } }

          it "extracts notification_id from the returned letter payload" do
            perform_now

            expect(Airbrake).to have_received(:notify).with(
              an_instance_of(StandardError),
              hash_including(notification_id: "letter-uuid")
            )
          end
        end
      end
    end
  end
end
