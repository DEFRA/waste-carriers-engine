# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify
    RSpec.describe InvitationInstructionsEmailService do
      describe ".send_email" do
        let(:template_id) { "5b5c1a42-b19b-4dc1-bece-4842f42edb65" }
        let(:user) { create(:user, email: "test@example.com") }
        let(:invite_url) { "http://example.com/invite" }
        let(:service_url) { "http://example.com/service" }
        let(:invitation_due_at) { "01/01/2020" }
        let(:opts) do
          {
            invite_url: invite_url,
            service_url: service_url,
            invitation_due_at: invitation_due_at
          }
        end
        let(:token) { "example_token" }

        let(:expected_notify_options) do
          {
            email_address: user.email,
            template_id: template_id,
            personalisation: {
              invite_link: invite_url,
              service_link: service_url,
              expiry_date: invitation_due_at
            }
          }
        end

        let(:notifications_client) { instance_double(Notifications::Client) }

        before do
          allow(Notifications::Client).to receive(:new).and_return(notifications_client)
          allow(notifications_client).to receive(:send_email)

          described_class.new.send_email(user, opts)
        end

        context "with an email" do
          it "sends an email" do
            expect(notifications_client).to have_received(:send_email).with(expected_notify_options)
          end
        end

        context "with no email" do
          before { user.email = nil }

          it "sends an email" do
            expect(notifications_client).not_to have_received(:send_email).with(expected_notify_options)
          end
        end
      end
    end
  end
end
