# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayValidatorService do
    let(:transient_registration) do
      create(:renewing_registration,
             :has_required_data,
             :has_overseas_addresses,
             :has_finance_details,
             temp_cards: 0)
    end
    let(:payment) { Payment.new_from_online_payment(transient_registration.finance_details.orders.first, nil) }
    let(:order) { transient_registration.finance_details.orders.first }
    let(:govpay_validator_service) { GovpayValidatorService.new(order, payment.uuid, govpay_status) }
    let(:govpay_host) { "https://publicapi.payments.service.gov.uk" }

    before do
      allow(WasteCarriersEngine::FeatureToggle).to receive(:active?).with(:govpay_payments).and_return(true)
      allow(Rails.configuration).to receive(:govpay_url).and_return(govpay_host)
      allow(Rails.configuration).to receive(:renewal_charge).and_return(10_500)

      # current_user = build(:user)
      # # We need to set a specific time so we know what order code to expect
      # Timecop.freeze(Time.new(2018, 1, 1)) do
      #   transient_registration.prepare_for_payment(:govpay, current_user)
      # end
    end

    shared_examples "valid and invalid Govpay status" do |method, valid_status, invalid_status|
      context "when the payment status is valid" do
        let(:govpay_status) { valid_status }

        it "returns true" do
          expect(govpay_validator_service.public_send(method)).to eq(true)
        end
      end

      context "when the payment status is invalid" do
        let(:govpay_status) { invalid_status }

        it "returns false" do
          expect(govpay_validator_service.public_send(method)).to eq(false)
        end
      end
    end

    describe "valid_success?" do
      let(:govpay_status) { "success" }
      context "when the govpay status is valid" do

        it "returns true" do
          expect(govpay_validator_service.valid_success?).to eq(true)
        end
      end

      context "when the govpay status is not valid" do

        let(:govpay_status) { "failed" }
        it "returns false" do
          expect(govpay_validator_service.valid_success?).to eq(false)
        end
      end

      context "when the order is not present" do
        let(:order) { nil }

        it "returns false" do
          expect(govpay_validator_service.valid_success?).to eq(false)
        end
      end

      context "when the payment_uuid is not present" do
        let(:govpay_validator_service) { GovpayValidatorService.new(order, nil, govpay_status) }

        it "returns false" do
          expect(govpay_validator_service.valid_success?).to eq(false)
        end
      end

      context "when the payment_uuid is invalid" do
        let(:govpay_validator_service) { GovpayValidatorService.new(order, "bad_payment_uuid", govpay_status) }

        it "returns false" do
          expect(govpay_validator_service.valid_success?).to eq(false)
        end
      end
    end

    describe "valid_failure?" do
      it_behaves_like "valid and invalid Govpay status", "valid_failure?", "failed"
    end

    describe "valid_pending?" do
      it_behaves_like "valid and invalid Govpay status", "valid_pending?", "created"
    end

    describe "valid_cancel?" do
      it_behaves_like "valid and invalid Govpay status", "valid_cancel?", "cancelled"
    end

    describe "valid_error?" do
      it_behaves_like "valid and invalid Govpay status", "valid_error?", "error"
    end

    describe "valid_govpay_status?" do
      it "returns true when the status matches the values for the response type" do
        expect(described_class.valid_govpay_status?(:success, "success")).to eq(true)
      end

      it "returns false when the status does not match the values for the response type" do
        expect(described_class.valid_govpay_status?(:success, "FOO")).to eq(false)
      end
    end
  end
end