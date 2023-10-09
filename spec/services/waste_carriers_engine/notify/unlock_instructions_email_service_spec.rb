# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify
    RSpec.describe UnlockInstructionsEmailService do
      describe ".run" do
        let(:template_id) { "a3295516-26a6-4c01-9e3a-d5000f1a86c6" }
        let(:user) { create(:user, email: "test@example.com") } # Assuming you have a factory for User
        let(:token) { "example_token" }

        let(:expected_notify_options) do
          {
            email_address: user.email,
            template_id: template_id,
            personalisation: {
              unlock_link: Rails.application.routes.url_helpers.unlock_url(
                user,
                host: Rails.configuration.wcrs_back_office_url,
                unlock_token: token
              )
            }
          }
        end

        context "with an email" do
          before do
            allow_any_instance_of(Notifications::Client)
              .to receive(:send_email)
              .with(expected_notify_options)
              .and_call_original
          end

          subject(:run_service) do
            described_class.new.run(template: template_id, record: user, opts: { token: token })
          end

          it "sends an email" do
            expect(run_service).to be_a(Notifications::Client::ResponseNotification)
            expect(run_service.template["id"]).to eq(template_id)
          end
        end

        context "with no email" do
          before { user.email = nil }

          it "does not attempt to send an email" do
            expect_any_instance_of(Notifications::Client).not_to receive(:send_email)

            described_class.new.run(template: template_id, record: user, opts: { token: token })
          end
        end
      end
    end
  end
end

