# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe WorldpayValidatorService do
    let(:transient_registration) do
      create(:renewing_registration,
             :has_required_data,
             :has_overseas_addresses,
             :has_finance_details,
             temp_cards: 0)
    end

    before do
      allow(Rails.configuration).to receive(:worldpay_admin_code).and_return("ADMIN_CODE")
      allow(Rails.configuration).to receive(:worldpay_merchantcode).and_return("MERCHANTCODE")
      allow(Rails.configuration).to receive(:worldpay_macsecret).and_return("5r2zsonhn2t69s1q9jsub90l0ljrs59r")
      allow(Rails.configuration).to receive(:renewal_charge).and_return(10_500)

      current_user = build(:user)
      # We need to set a specific time so we know what order code to expect
      Timecop.freeze(Time.new(2018, 1, 1)) do
        WasteCarriersEngine::FinanceDetails.new_finance_details(transient_registration, :worldpay, current_user)
      end
    end

    let(:order) { transient_registration.finance_details.orders.first }
    let(:params) do
      {
        orderKey: "#{Rails.configuration.worldpay_admin_code}^#{Rails.configuration.worldpay_merchantcode}^#{order.order_code}",
        paymentStatus: "REFUSED",
        paymentAmount: order.total_amount,
        paymentCurrency: "GBP",
        mac: "b32f74da10bf1d9ebfd262d673e58fb9",
        source: "WP",
        reg_identifier: transient_registration.reg_identifier
      }
    end

    let(:worldpay_validator_service) { WorldpayValidatorService.new(order, params) }

    describe "valid_success?" do
      let(:params) do
        {
          orderKey: "#{Rails.configuration.worldpay_admin_code}^#{Rails.configuration.worldpay_merchantcode}^#{order.order_code}",
          paymentStatus: "AUTHORISED",
          paymentAmount: order.total_amount,
          paymentCurrency: "GBP",
          mac: "10c661a3e57360554675167982ca9948",
          source: "WP",
          reg_identifier: transient_registration.reg_identifier
        }
      end

      it "returns true" do
        expect(worldpay_validator_service.valid_success?).to eq(true)
      end

      context "when the orderKey is in the wrong format" do
        before do
          params[:orderKey] = "foo#{order.order_code}"
          # Change the MAC param to still be valid as this relies on the orderKey
          params[:mac] = "590d7ced56f44fd472fdf563ade0730b"
        end

        it "returns false" do
          expect(worldpay_validator_service.valid_success?).to eq(false)
        end
      end

      context "when the paymentStatus is invalid" do
        before do
          allow(Order).to receive(:valid_world_pay_status?).and_return(false)
        end

        it "returns false" do
          expect(worldpay_validator_service.valid_success?).to eq(false)
        end
      end

      context "when the paymentAmount is invalid" do
        before do
          params[:paymentAmount] = 42
          # Change the MAC param to still be valid as this relies on the paymentAmount
          params[:mac] = "926883e7cf68b253503446d9cc50f60d"
        end

        it "returns false" do
          expect(worldpay_validator_service.valid_success?).to eq(false)
        end
      end

      context "when the paymentCurrency is invalid" do
        before do
          params[:paymentCurrency] = "foo"
          # Change the MAC param to still be valid as this relies on the paymentCurrency
          params[:mac] = "838742835243dd1053e92b3b0135c905"
        end

        it "returns false" do
          expect(worldpay_validator_service.valid_success?).to eq(false)
        end
      end

      context "when the mac is invalid" do
        before do
          params[:mac] = "foo"
        end

        it "returns false" do
          expect(worldpay_validator_service.valid_success?).to eq(false)
        end
      end
    end

    describe "valid_failure?" do
      before do
        params[:paymentStatus] = "REFUSED"
      end

      it "returns true" do
        expect(worldpay_validator_service.valid_failure?).to eq(true)
      end

      context "when the paymentStatus is invalid" do
        before do
          allow(Order).to receive(:valid_world_pay_status?).and_return(false)
        end

        it "returns false" do
          expect(worldpay_validator_service.valid_failure?).to eq(false)
        end
      end
    end

    describe "valid_pending?" do
      before do
        params[:paymentStatus] = "SENT_FOR_AUTHORISATION"
        # Change the MAC param to still be valid as this relies on the paymentStatus
        params[:mac] = "439facf7d9e31b4e6a4b35478803ff6f"
      end

      it "returns true" do
        expect(worldpay_validator_service.valid_pending?).to eq(true)
      end

      context "when the paymentStatus is invalid" do
        before do
          allow(Order).to receive(:valid_world_pay_status?).and_return(false)
        end

        it "returns false" do
          expect(worldpay_validator_service.valid_pending?).to eq(false)
        end
      end
    end

    describe "valid_cancel?" do
      context "when the paymentStatus is cancelled and params are valid" do
        let(:params) do
          {
            orderKey: "#{Rails.configuration.worldpay_admin_code}^#{Rails.configuration.worldpay_merchantcode}^#{order.order_code}",
            paymentStatus: "CANCELLED",
            paymentAmount: order.total_amount,
            paymentCurrency: "GBP",
            mac: "dc28800817046640f33846ff5835839a",
            source: "WP",
            reg_identifier: transient_registration.reg_identifier
          }
        end

        it "returns true" do
          expect(worldpay_validator_service.valid_cancel?).to eq(true)
        end

        context "when the paymentStatus is invalid" do
          before do
            allow(Order).to receive(:valid_world_pay_status?).and_return(false)
          end

          it "returns false" do
            expect(worldpay_validator_service.valid_cancel?).to eq(false)
          end
        end
      end
    end

    describe "valid_error?" do
      before do
        params[:paymentStatus] = "ERROR"
        # Change the MAC param to still be valid as this relies on the paymentStatus
        params[:mac] = "850b1aaf91a079cd888fe9a848835cd5"
      end

      it "returns true" do
        expect(worldpay_validator_service.valid_error?).to eq(true)
      end

      context "when the paymentStatus is invalid" do
        before do
          allow(Order).to receive(:valid_world_pay_status?).and_return(false)
        end

        it "returns false" do
          expect(worldpay_validator_service.valid_error?).to eq(false)
        end
      end
    end
  end
end
