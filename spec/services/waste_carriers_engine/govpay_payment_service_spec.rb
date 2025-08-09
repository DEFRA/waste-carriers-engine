# frozen_string_literal: true

require "webmock/rspec"
require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayPaymentService do
    let(:govpay_host) { "https://publicapi.payments.service.gov.uk" }
    let(:transient_registration) do
      create(:renewing_registration,
             :has_required_data,
             :has_overseas_addresses,
             :has_finance_details,
             temp_cards: 0)
    end
    let(:order) { transient_registration.finance_details.orders.first }
    let(:govpay_service) { described_class.new(transient_registration, order) }

    before do
      allow(Rails.configuration).to receive(:govpay_url).and_return(govpay_host)
      allow(Rails.configuration).to receive(:renewal_charge).and_return(Rails.configuration.renewal_charge)

      transient_registration.prepare_for_payment(:govpay)

      stub_request(:any, /.*#{govpay_host}.*/).to_return(
        status: 200,
        body: File.read("./spec/fixtures/files/govpay/create_payment_created_response.json")
      )
    end

    describe "prepare_for_payment" do
      let(:defra_ruby_govpay_api) { DefraRubyGovpay::API.new(host_is_back_office:) }
      let(:host_is_back_office) { WasteCarriersEngine.configuration.host_is_back_office? }

      before do
        allow(DefraRubyGovpay::API).to receive(:new).and_return(defra_ruby_govpay_api)
        allow(defra_ruby_govpay_api).to receive(:send_request).with(anything).and_call_original
      end

      context "when the request is valid" do
        it "returns a link" do
          url = govpay_service.prepare_for_payment[:url]
          # expect the value from the payment response file fixture
          expect(url).to eq("https://www.payments.service.gov.uk/secure/bb0a272c-8eaf-468d-b3xf-ae5e000d2231")
        end

        # Including this test because the Worldpay equivalent does create a new payment
        it "does not create a new payment" do
          expect { govpay_service.prepare_for_payment }.not_to change { transient_registration.finance_details.payments.length }
        end

        context "when the request is from the back-office" do
          before do
            allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(true)
            allow(defra_ruby_govpay_api).to receive(:send_request).with(anything).and_call_original
          end

          it "sends the moto flag to GovPay" do
            govpay_service.prepare_for_payment

            expect(defra_ruby_govpay_api).to have_received(:send_request).with(
              is_moto: true,
              method: :post,
              path: anything,
              params: hash_including(moto: true)
            )
          end
        end

        context "when the request is from the front-office" do
          before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(false) }

          it "does not send the moto flag to GovPay" do
            govpay_service.prepare_for_payment

            expect(defra_ruby_govpay_api).to have_received(:send_request).with(
              is_moto: false,
              method: :post,
              path: anything,
              params: hash_not_including(moto: true)
            )
          end
        end
      end

      context "when the request is invalid" do
        before do
          stub_request(:any, /.*#{govpay_host}.*/).to_return(
            status: 200,
            body: File.read("./spec/fixtures/files/govpay/create_payment_error_response.json")
          )
        end

        it "returns :error" do
          expect(govpay_service.prepare_for_payment).to eq(:error)
        end
      end
    end

    describe "#payment_callback_url" do
      let(:callback_host) { Faker::Internet.url }

      before { allow(Rails.configuration).to receive(:host).and_return(callback_host) }

      subject(:callback_url) { govpay_service.payment_callback_url }

      context "when the order does not exist" do

        before { transient_registration.finance_details.orders = [] }

        it "raises an exception" do
          expect { callback_url }.to raise_error(StandardError)
        end
      end

      context "when the order exists" do

        it "the callback url includes the base path" do
          expect(callback_url).to start_with(callback_host)
        end

        it "the callback url includes the payment uuid" do
          expect(callback_url).to include(TransientRegistration.first.finance_details.orders.first.payment_uuid)
        end
      end
    end
  end
end
