require "rails_helper"

RSpec.describe WorldpayValidatorService do
  let(:transient_registration) do
    create(:transient_registration,
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

    # We need to set a specific time so we know what order code to expect
    Timecop.freeze(Time.new(2018, 1, 1)) do
      FinanceDetails.new_finance_details(transient_registration)
    end
  end

  let(:order) { transient_registration.finance_details.orders.first }
  let(:params) {}

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
        params[:paymentStatus] = "foo"
        # Change the MAC param to still be valid as this relies on the paymentStatus
        params[:mac] = "ecf0c84b1efa523ae847dd26cdf7b798"
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

    context "when the source is invalid" do
      before do
        params[:source] = "foo"
      end

      it "returns false" do
        expect(worldpay_validator_service.valid_success?).to eq(false)
      end
    end
  end

  describe "valid_failure?" do
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

    it "returns true" do
      expect(worldpay_validator_service.valid_failure?).to eq(true)
    end

    # We test most of the individual param validations when testing :valid_success?,
    # so just test the unique ones for :valid_failure?
    context "when the paymentStatus is invalid" do
      before do
        params[:paymentStatus] = "foo"
        # Change the MAC param to still be valid as this relies on the paymentStatus
        params[:mac] = "ecf0c84b1efa523ae847dd26cdf7b798"
      end

      it "returns false" do
        expect(worldpay_validator_service.valid_failure?).to eq(false)
      end
    end
  end
end
