# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "UnsubscribeController" do
    describe "GET /unsubscribe/:unsubscribe_token" do
      let(:registration) { create(:registration, :has_required_data) }
      let(:unsubscribe_token) { registration.unsubscribe_token }

      context "when the unsubscribe token is invalid" do
        it "redirects to the unsubscribe failed page" do
          get unsubscribe_path(unsubscribe_token: "invalid_token")
          expect(response).to redirect_to(unsubscribe_failed_path)
        end
      end

      context "when the unsubscribe token is valid" do
        it "updates the registration's communications_opted_in attribute to false" do
          get unsubscribe_path(unsubscribe_token:)
          registration.reload
          expect(registration.communications_opted_in).to be(false)
        end

        it "redirects to the unsubscribe successful page" do
          get unsubscribe_path(unsubscribe_token:)
          expect(response).to redirect_to(unsubscribe_successful_path)
        end

        it "creates a communication record" do
          expect { get unsubscribe_path(unsubscribe_token:) }
            .to change { registration.communication_records.count }.by(1)
        end

        it "uses the correct communication record type" do
          get unsubscribe_path(unsubscribe_token:)

          expect(registration.communication_records.last.notification_type).to eq "unsubscribed"
        end
      end
    end
  end
end
