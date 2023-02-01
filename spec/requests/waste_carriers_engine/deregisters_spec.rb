# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "Deregisters" do
    describe "GET deregister_path" do
      context "when the deregistration token is valid" do
        let(:active) { true }
        let(:token_created_at) { 2.days.ago }
        let(:registration) do
          create(:registration, :has_required_data,
                 (active ? :is_active : :is_inactive),
                 deregistration_token: "X123",
                 deregistration_token_created_at: token_created_at)
        end

        let(:magic_link_service) { instance_double(DeregistrationMagicLinkService) }
        let(:email_service) { instance_double(Notify::DeregistrationEmailService) }

        before do
          allow(DeregistrationMagicLinkService).to receive(:new).and_return(magic_link_service)
          allow(magic_link_service).to receive(:run)
          allow(Notify::DeregistrationEmailService).to receive(:new).and_return(email_service)
          allow(email_service).to receive(:run)

          get deregister_path(token: registration.deregistration_token)
        end

        it "returns a 302 response" do
          expect(response).to have_http_status(:found)
        end

        it "redirects to the deregistration start form" do
          expect(response).to redirect_to(new_deregistration_confirmation_form_path(registration.deregistration_token))
        end

        context "when the token has expired" do
          let(:token_created_at) { 3.months.ago }

          it "returns a 422 response code" do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "renders the correct template" do
            expect(response).to render_template(:deregistration_link_expired)
          end

          it "re-sends the deregistration email" do
            expect(email_service).to have_received(:run)
          end
        end

        context "when the registration has already been deactivated" do
          let(:active) { false }

          it "returns a 422 response code" do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "renders the correct template" do
            expect(response).to render_template(:already_ceased)
          end
        end
      end

      context "when the deregistration token is invalid" do
        before { get deregister_path(token: "FooBarBaz") }

        it "returns a 404 response code" do
          expect(response).to have_http_status(:not_found)
        end

        it "renders the correct template" do
          expect(response).to render_template(:invalid_deregistration_link)
        end
      end
    end
  end
end
