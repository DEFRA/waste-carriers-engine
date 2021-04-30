# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify
    RSpec.describe CopyCardsOrderCompletedEmailService do
      describe ".run" do
        let(:template_id) { "543a89cd-056e-4e9b-a55b-6416980f5472" }
        let(:registration) { create(:registration, :has_required_data, :has_copy_cards_order) }
        let(:order) { registration.finance_details.orders.last }

        let(:expected_notify_options) do
          {
            email_address: "foo@example.com",
            template_id: template_id,
            personalisation: {
              reg_identifier: registration.reg_identifier,
              first_name: "Jane",
              last_name: "Doe",
              total_cards: 1,
              ordered_on: order.date_created.to_datetime.to_formatted_s(:day_month_year),
              total_paid: "5"
            }
          }
        end

        before do
          expect_any_instance_of(Notifications::Client)
            .to receive(:send_email)
            .with(expected_notify_options)
            .and_call_original
        end

        subject do
          VCR.use_cassette("notify_copy_cards_order_completed_sends_an_email") do
            described_class.run(registration: registration, order: order)
          end
        end

        it "sends an email" do
          expect(subject).to be_a(Notifications::Client::ResponseNotification)
          expect(subject.template["id"]).to eq(template_id)
          expect(subject.content["subject"]).to eq("We’re printing your waste carriers registration cards")
        end
      end
    end
  end
end
