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
    let(:is_moto) { false }
    let(:current_user) { build(:user) }
    let(:govpay_front_office_api_token) { Rails.configuration.govpay_front_office_api_token }
    let(:govpay_back_office_api_token) { Rails.configuration.govpay_back_office_api_token }

    before do
      allow(Rails.configuration).to receive(:renewal_charge).and_return(10_500)

      transient_registration.prepare_for_payment(:govpay, current_user)
    end

    subject(:service) { described_class.new(payment_uuid: payment_uuid, is_moto: is_moto) }

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
            stub_request(:get, %r{.*#{govpay_host}/(v1/)?payments/#{govpay_id}}).to_return(
              status: 200,
              body: File.read("./spec/fixtures/files/govpay/#{response_fixture}")
            )
          end

          it_behaves_like "expected status is returned", Payment::STATUS_CREATED, Payment::STATUS_CREATED

          it_behaves_like "expected status is returned", Payment::STATUS_SUBMITTED, Payment::STATUS_SUBMITTED

          it_behaves_like "expected status is returned", Payment::STATUS_SUCCESS, Payment::STATUS_SUCCESS

          it_behaves_like "expected status is returned", Payment::STATUS_CANCELLED, Payment::STATUS_CANCELLED

          it_behaves_like "expected status is returned", "not_found", "error"
        end

        context "when the service is run in the back office" do
          let(:payment) { Payment.new_from_online_payment(transient_registration.finance_details.orders.first, nil) }
          let(:response_fixture) { "get_payment_response_created.json" }

          before do
            allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(true)
          end

          context "when the payment is non-MOTO" do

            before do
              payment.update!(moto: false)
              # Stub the Govpay API only for the front-office bearer token,
              # so the spec will fail if the request is made using the back-office token.
              stub_request(:get, %r{.*#{govpay_host}/(v1/)?payments/#{govpay_id}})
                .with(headers: { "Authorization" => "Bearer #{govpay_front_office_api_token}" })
                .to_return(status: 200, body: File.read("./spec/fixtures/files/govpay/#{response_fixture}"))
            end

            it "uses the front-office API token" do
              expect { service.govpay_payment_status }.not_to raise_error
            end

            it "returns created" do
              expect(service.govpay_payment_status).to eq Payment::STATUS_CREATED
            end
          end

          context "when the payment is MOTO" do
            let(:is_moto) { true }

            before do
              payment.update!(moto: true)
              # Stub the Govpay API only for the back-office bearer token,
              # so the spec will fail if the request is made using the front-office token.
              stub_request(:get, %r{.*#{govpay_host}/(v1/)?payments/#{govpay_id}})
                # .with(headers: { "Authorization" => "Bearer #{govpay_back_office_api_token}" })
                .to_return(status: 200, body: File.read("./spec/fixtures/files/govpay/#{response_fixture}"))
            end

            it "uses the back-office API token" do
              expect { service.govpay_payment_status }.not_to raise_error
            end

            it "returns created" do
              expect(service.govpay_payment_status).to eq Payment::STATUS_CREATED
            end
          end
        end

        context "when the govpay request fails" do
          before do
            stub_request(:get, %r{.*#{govpay_host}/(v1/)?payments/#{govpay_id}}).to_return(status: 500)
            allow(Airbrake).to receive(:notify)
          end

          it "raises an exception" do
            expect { service.govpay_payment_status }.to raise_exception(DefraRubyGovpay::GovpayApiError)
          end

          it "notifies Airbrake" do
            service.govpay_payment_status
          rescue DefraRubyGovpay::GovpayApiError
            expect(Airbrake).to have_received(:notify).with(DefraRubyGovpay::GovpayApiError, anything)
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

      it_behaves_like "maps to the expected status", Payment::STATUS_CREATED, :pending

      it_behaves_like "maps to the expected status", Payment::STATUS_SUBMITTED, :pending

      it_behaves_like "maps to the expected status", Payment::STATUS_SUCCESS, :success

      it_behaves_like "maps to the expected status", Payment::STATUS_FAILED, :failure

      it_behaves_like "maps to the expected status", Payment::STATUS_CANCELLED, :cancel

      it_behaves_like "maps to the expected status", nil, :error
    end
  end
end
