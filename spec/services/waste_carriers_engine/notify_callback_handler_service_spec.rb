# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NotifyCallbackHandlerService do
    let(:registration) { create(:registration, :has_required_data) }
    let(:notification_id) { "740e5834-3a29-46b4-9a6f-16142fde533a" }
    let(:communication_record) do
      registration.communication_records.create(
        notify_template_id: "f33517ff-2a88-4f6e-b855-c550268ce08a",
        notification_id: notification_id,
        notification_type: "email",
        comms_label: "Test email",
        sent_at: Time.now.utc,
        sent_to: "recipient@example.com",
        delivery_status: "sent"
      )
    end

    describe ".run" do
      context "with a delivery receipt callback" do
        let(:payload) do
          {
            "id" => notification_id,
            "reference" => "CBDU999999",
            "to" => "recipient@example.com",
            "status" => "delivered",
            "notification_type" => "email"
          }
        end

        before { communication_record }

        it "updates the communication record delivery status" do
          expect { described_class.run(payload) }
            .to change { communication_record.reload.delivery_status }
            .from("sent")
            .to("delivered")
        end

        it "returns the notification_id and new status" do
          result = described_class.run(payload)

          expect(result).to eq(notification_id: notification_id, status: "delivered")
        end

        %w[permanent-failure temporary-failure technical-failure].each do |status|
          context "when status is #{status}" do
            let(:payload) do
              {
                "id" => notification_id,
                "status" => status,
                "notification_type" => "email"
              }
            end

            it "updates the communication record delivery status to #{status}" do
              expect { described_class.run(payload) }
                .to change { communication_record.reload.delivery_status }
                .from("sent")
                .to(status)
            end
          end
        end

        context "when the communication record is not found" do
          let(:payload) do
            {
              "id" => "unknown-uuid",
              "status" => "delivered",
              "notification_type" => "email"
            }
          end

          it "returns not_found status" do
            result = described_class.run(payload)

            expect(result).to eq(notification_id: "unknown-uuid", status: "not_found")
          end

          it "logs a warning" do
            allow(Rails.logger).to receive(:warn)

            described_class.run(payload)

            expect(Rails.logger).to have_received(:warn).with(/not found/)
          end
        end

        context "when the communication record already has a terminal delivery status" do
          before { communication_record.update!(delivery_status: "delivered") }

          it "does not change the delivery status" do
            expect { described_class.run(payload) }
              .not_to change { communication_record.reload.delivery_status }
          end

          it "returns the existing terminal status" do
            result = described_class.run(payload)

            expect(result).to eq(notification_id: notification_id, status: "delivered")
          end
        end

        context "when id is missing" do
          let(:payload) { { "status" => "delivered", "notification_type" => "email" } }

          it "raises an ArgumentError" do
            expect { described_class.run(payload) }.to raise_error(ArgumentError, /Missing id/)
          end
        end

        context "when status is missing" do
          let(:payload) { { "id" => notification_id, "notification_type" => "email" } }

          it "raises an ArgumentError" do
            expect { described_class.run(payload) }.to raise_error(ArgumentError, /Missing status/)
          end
        end
      end

      context "with a returned letter callback" do
        let(:payload) do
          {
            "notification_id" => notification_id,
            "reference" => "CBDU999999",
            "date_sent" => "2026-07-08T12:15:30.000000Z",
            "template_name" => "confirmation_letter",
            "template_id" => "f33517ff-2a88-4f6e-b855-c550268ce08a",
            "template_version" => 1
          }
        end

        before { communication_record }

        it "updates the communication record delivery status to returned" do
          expect { described_class.run(payload) }
            .to change { communication_record.reload.delivery_status }
            .from("sent")
            .to("returned")
        end

        it "returns the notification_id and returned status" do
          result = described_class.run(payload)

          expect(result).to eq(notification_id: notification_id, status: "returned")
        end

        context "when notification_id is blank" do
          let(:payload) { { "notification_id" => "", "template_name" => "confirmation_letter" } }

          it "raises an ArgumentError" do
            expect { described_class.run(payload) }.to raise_error(ArgumentError, /Missing notification_id/)
          end
        end
      end

      context "with an unrecognised payload" do
        let(:payload) { { "foo" => "bar" } }

        it "raises an ArgumentError" do
          expect { described_class.run(payload) }.to raise_error(ArgumentError, /Unrecognised/)
        end
      end
    end
  end
end
