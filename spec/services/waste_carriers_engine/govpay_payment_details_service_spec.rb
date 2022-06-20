# frozen_string_literal: true

require "webmock/rspec"
require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayPaymentDetailsService do
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

    subject { GovpayPaymentDetailsService.new(transient_registration.finance_details.orders.first.payment_uuid) }

    describe "govpay_payment_status" do

      context "with an invalid payment uuid" do
        it "raises an exception" do
          expect { GovpayPaymentDetailsService.new("bad_uuid") }.to raise_exception(ArgumentError)
        end
      end

      context "with a valid payment uuid" do
        shared_examples "expected status is returned" do |govpay_status, expected_status|
          let(:response_fixture) { "get_payment_response_#{govpay_status}.json" }

          it "returns #{expected_status}" do
            expect(subject.govpay_payment_status).to eq expected_status
          end
        end

        before do
          stub_request(:get, /.*#{govpay_host}.*/).to_return(
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
    end

    describe "payment_status" do

      shared_examples "maps to the expected status" do |govpay_status, response_type|
        it "returns the correct status" do
          expect(GovpayPaymentDetailsService.response_type(govpay_status)).to eq response_type
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
