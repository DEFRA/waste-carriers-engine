# frozen_string_literal: true

require "webmock/rspec"
require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayPaymentDetailsService do
    let(:govpay_host) { "https://publicapi.payments.service.gov.uk" }
    let(:transient_registration) do
      create(:renewing_registration,
             :has_required_data,
             :has_overseas_addresses,
             :has_finance_details,
             temp_cards: 0)
    end
    let(:valid_payment_uuid) { transient_registration.finance_details.orders.first.payment_uuid }
    let(:payment_uuid) { valid_payment_uuid }
    let(:order) { transient_registration.finance_details.orders.first }
    let(:current_user) { build(:user) }

    before do
      allow(WasteCarriersEngine::FeatureToggle).to receive(:active?).with(:govpay_payments).and_return(true)
      allow(Rails.configuration).to receive(:govpay_url).and_return(govpay_host)
      allow(Rails.configuration).to receive(:renewal_charge).and_return(10_500)

      transient_registration.prepare_for_payment(:govpay, current_user)
    end

    subject(:service) { described_class.new(payment_uuid: payment_uuid) }

    describe "govpay_payment_status" do

      context "with an invalid payment uuid" do
        let(:payment_uuid) { "bad_uuid" }

        before { allow(Airbrake).to receive(:notify) }

        it "raises an exception" do
          expect { service.govpay_payment_status }.to raise_exception(ArgumentError)
        end

        it "notifies Airbrake" do
          service.govpay_payment_status
        rescue ArgumentError
          expect(Airbrake).to have_received(:notify).with(StandardError, hash_including(payment_uuid: payment_uuid))
        end
      end

      context "with a valid payment uuid" do
        shared_examples "expected status is returned" do |govpay_status, expected_status|
          let(:response_fixture) { "get_payment_response_#{govpay_status}.json" }

          it "returns #{expected_status}" do
            expect(service.govpay_payment_status).to eq expected_status
          end
        end

        let(:govpay_id) { "a-valid-govpay-payment-id" }

        before do
          order.govpay_id = govpay_id
          transient_registration.save!
        end

        context "when the govpay request succeeds" do
          before do
            stub_request(:get, %r{.*#{govpay_host}/payments/#{govpay_id}}).to_return(
              status: 200,
              body: File.read("./spec/fixtures/files/govpay/#{response_fixture}")
            )
          end

          it_behaves_like "expected status is returned", "created", "created"

          it_behaves_like "expected status is returned", "submitted", "submitted"

          it_behaves_like "expected status is returned", "success", "success"

          it_behaves_like "expected status is returned", "cancelled", "cancelled"

          it_behaves_like "expected status is returned", "not_found", "error"
        end

        context "when the payment is non-MOTO and the request is run from the back-office" do
          let(:payment) { Payment.new_from_online_payment(transient_registration.finance_details.orders.first, nil) }
          let(:response_fixture) { "get_payment_response_created.json" }
          let(:govpay_api_token) { "front_office_token" }

          before do
            # This ensures that the Govpay API is not stubbed for the back office bearer token,
            # so the spec will fail if the request is made using the back office token.
            stub_request(:get, %r{.*#{govpay_host}/payments/#{govpay_id}})
              .with(headers: { "Authorization" => "Bearer #{govpay_api_token}" })
              .to_return(
                status: 200,
                body: File.read("./spec/fixtures/files/govpay/#{response_fixture}")
              )

            allow(Rails.configuration).to receive(:govpay_front_office_api_token).and_return(govpay_api_token)
            allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(true)
            payment.update!(moto: false)
          end

          it "uses the front-office API token and returns created" do
            expect(service.govpay_payment_status).to eq "created"
          end
        end

        context "when the govpay request fails" do
          before do
            stub_request(:get, %r{.*#{govpay_host}/payments/#{govpay_id}}).to_return(status: 500)
            allow(Airbrake).to receive(:notify)
          end

          it "raises an exception" do
            expect { service.govpay_payment_status }.to raise_exception(GovpayApiError)
          end

          it "notifies Airbrake" do
            service.govpay_payment_status
          rescue GovpayApiError
            expect(Airbrake).to have_received(:notify).with(RestClient::InternalServerError,
                                                            hash_including(
                                                              message: "Error sending govpay request",
                                                              path: "/payments/#{govpay_id}"
                                                            ))
          end
        end
      end
    end

    describe "payment_status" do

      shared_examples "maps to the expected status" do |govpay_status, expected_status|
        it "returns the correct status" do
          expect(described_class.payment_status(govpay_status)).to eq expected_status
        end
      end

      it_behaves_like "maps to the expected status", "created", :pending

      it_behaves_like "maps to the expected status", "submitted", :pending

      it_behaves_like "maps to the expected status", "success", :success

      it_behaves_like "maps to the expected status", "failed", :failure

      it_behaves_like "maps to the expected status", "cancelled", :cancel

      it_behaves_like "maps to the expected status", nil, :error
    end
  end
end
