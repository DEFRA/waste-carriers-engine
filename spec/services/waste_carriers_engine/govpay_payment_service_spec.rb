# frozen_string_literal: true

require "webmock/rspec"
require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayPaymentService do
    let(:govpay_host) { "https://publicapi.payments.service.gov.uk" }
    before do
      allow(WasteCarriersEngine::FeatureToggle).to receive(:active?).with(:govpay_payments).and_return(true)
      allow(Rails.configuration).to receive(:govpay_url).and_return(govpay_host)
    end

    let(:transient_registration) do
      create(:renewing_registration,
             :has_required_data,
             :has_overseas_addresses,
             :has_finance_details,
             temp_cards: 0)
    end
    let(:current_user) { build(:user) }

    before do
      allow(Rails.configuration).to receive(:renewal_charge).and_return(10_500)

      transient_registration.prepare_for_payment(:govpay, current_user)
    end

    let(:order) { transient_registration.finance_details.orders.first }

    let(:govpay_service) { GovpayPaymentService.new(transient_registration, order, current_user) }

    before do
      stub_request(:any, /.*#{govpay_host}.*/).to_return(
        status: 200,
        body: File.read("./spec/fixtures/files/govpay/create_payment_created_response.json")
      )
    end

    describe "prepare_for_payment" do
      context "when the request is valid" do
        let(:root) { Rails.configuration.wcrs_renewals_url }
        let(:reg_id) { transient_registration.reg_identifier }

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
          before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(true) }

          it "sends the moto flag to GovPay" do
            expect(govpay_service).to receive(:send_request).with(anything, anything, hash_including(moto: true))
            govpay_service.prepare_for_payment
          end
        end

        context "when the request is from the front-office" do
          before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(false) }

          it "does not send the moto flag to GovPay" do
            expect(govpay_service).to receive(:send_request).with(anything, anything, hash_not_including(moto: true))
            govpay_service.prepare_for_payment
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

      before do
        allow(Rails.configuration).to receive(:host).and_return(callback_host)
      end

      subject { govpay_service.payment_callback_url }

      context "when the order does not exist" do

        before { transient_registration.finance_details.orders = [] }

        it "raises an exception" do
          expect { subject }.to raise_error(StandardError)
        end
      end

      context "when the order exists" do

        it "the callback url includes the base path" do
          expect(subject).to start_with(callback_host)
        end

        it "the callback url includes the payment uuid" do
          expect(subject).to include(TransientRegistration.first.finance_details.orders.first.payment_uuid)
        end
      end
    end
  end
end
