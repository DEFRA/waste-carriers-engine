# frozen_string_literal: true

RSpec.shared_examples "Can have payment type" do |resource:|
  describe "#cash?" do
    before do
      resource.payment_type = payment_type
    end

    context "when the payment type is cash" do
      let(:payment_type) { WasteCarriersEngine::Payment::CASH }

      it "returns true" do
        expect(resource.cash?).to eq(true)
      end
    end

    context "when the payment type is not cash" do
      let(:payment_type) { "foo" }

      it "returns false" do
        expect(resource.cash?).to eq(false)
      end
    end
  end

  describe "#bank_transfer?" do
    before do
      resource.payment_type = payment_type
    end

    context "when the payment type is bank_transfer" do
      let(:payment_type) { WasteCarriersEngine::Payment::BANKTRANSFER }

      it "returns true" do
        expect(resource.bank_transfer?).to eq(true)
      end
    end

    context "when the payment type is not bank_transfer" do
      let(:payment_type) { "foo" }

      it "returns false" do
        expect(resource.bank_transfer?).to eq(false)
      end
    end
  end

  describe "#online?" do
    before do
      resource.payment_type = payment_type
    end

    context "when the payment type is worldpay" do
      let(:payment_type) { WasteCarriersEngine::Payment::WORLDPAY }

      it "returns true" do
        expect(resource.online?).to eq(true)
      end
    end

    context "when the payment type is not worldpay" do
      let(:payment_type) { "foo" }

      it "returns false" do
        expect(resource.online?).to eq(false)
      end
    end
  end

  describe "#online_missed?" do
    before do
      resource.payment_type = payment_type
    end

    context "when the payment type is worldpay_missed" do
      let(:payment_type) { WasteCarriersEngine::Payment::WORLDPAY_MISSED }

      it "returns true" do
        expect(resource.online_missed?).to eq(true)
      end
    end

    context "when the payment type is not worldpay_missed" do
      let(:payment_type) { "foo" }

      it "returns false" do
        expect(resource.online_missed?).to eq(false)
      end
    end
  end

  describe "#refund?" do
    before do
      resource.payment_type = payment_type
    end

    context "when the payment type is refund" do
      let(:payment_type) { WasteCarriersEngine::Payment::REFUND }

      it "returns true" do
        expect(resource.refund?).to eq(true)
      end
    end

    context "when the payment type is not refund" do
      let(:payment_type) { "foo" }

      it "returns false" do
        expect(resource.refund?).to eq(false)
      end
    end
  end

  describe "#writeoff_small?" do
    before do
      resource.payment_type = payment_type
    end

    context "when the payment type is writeoff_small" do
      let(:payment_type) { WasteCarriersEngine::Payment::WRITEOFFSMALL }

      it "returns true" do
        expect(resource.writeoff_small?).to eq(true)
      end
    end

    context "when the payment type is not writeoff_small" do
      let(:payment_type) { "foo" }

      it "returns false" do
        expect(resource.writeoff_small?).to eq(false)
      end
    end
  end

  describe "#writeoff_large?" do
    before do
      resource.payment_type = payment_type
    end

    context "when the payment type is writeoff_large" do
      let(:payment_type) { WasteCarriersEngine::Payment::WRITEOFFLARGE }

      it "returns true" do
        expect(resource.writeoff_large?).to eq(true)
      end
    end

    context "when the payment type is not writeoff_large" do
      let(:payment_type) { "foo" }

      it "returns false" do
        expect(resource.writeoff_large?).to eq(false)
      end
    end
  end

  describe "#reversal?" do
    before do
      resource.payment_type = payment_type
    end

    context "when the payment type is reversal" do
      let(:payment_type) { WasteCarriersEngine::Payment::REVERSAL }

      it "returns true" do
        expect(resource.reversal?).to eq(true)
      end
    end

    context "when the payment type is not reversal" do
      let(:payment_type) { "foo" }

      it "returns false" do
        expect(resource.reversal?).to eq(false)
      end
    end
  end

  describe "#cheque?" do
    before do
      resource.payment_type = payment_type
    end

    context "when the payment type is cheque" do
      let(:payment_type) { WasteCarriersEngine::Payment::CHEQUE }

      it "returns true" do
        expect(resource.cheque?).to eq(true)
      end
    end

    context "when the payment type is not cheque" do
      let(:payment_type) { "foo" }

      it "returns false" do
        expect(resource.cheque?).to eq(false)
      end
    end
  end

  describe "#postal_order?" do
    before do
      resource.payment_type = payment_type
    end

    context "when the payment type is postal_order" do
      let(:payment_type) { WasteCarriersEngine::Payment::POSTALORDER }

      it "returns true" do
        expect(resource.postal_order?).to eq(true)
      end
    end

    context "when the payment type is not postal_order" do
      let(:payment_type) { "foo" }

      it "returns false" do
        expect(resource.postal_order?).to eq(false)
      end
    end
  end
end
