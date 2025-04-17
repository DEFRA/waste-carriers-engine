# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GovpayFindRegistrationService do
    describe "#run" do
      let(:govpay_id) { "govpay-#{SecureRandom.uuid}" }
      let(:payment) { build(:payment, govpay_id: govpay_id) }

      subject(:run_service) { described_class.run(payment: payment) }

      context "when the payment is nil" do
        let(:payment) { nil }

        it "returns nil" do
          expect(run_service).to be_nil
        end
      end

      context "when the payment exists in a registration" do
        let!(:registration) do
          create(:registration, :has_required_data, finance_details: build(:finance_details, :has_required_data))
        end

        before do
          registration.finance_details.payments << payment
          registration.finance_details.update_balance
          registration.save!
        end

        it "returns the registration" do
          expect(run_service).to eq(registration)
        end
      end

      context "when the payment exists in a transient registration" do
        let!(:transient_registration) do
          create(:renewing_registration, :has_required_data, finance_details: build(:finance_details, :has_required_data))
        end

        before do
          transient_registration.finance_details.payments << payment
          transient_registration.finance_details.update_balance
          transient_registration.save!
        end

        it "returns the transient registration" do
          expect(run_service).to eq(transient_registration)
        end
      end

      context "when the payment does not exist in any registration" do
        it "returns nil" do
          expect(run_service).to be_nil
        end
      end

      context "when the payment exists in both a registration and a transient registration" do
        let!(:registration) do
          create(:registration, :has_required_data, finance_details: build(:finance_details, :has_required_data))
        end

        let!(:transient_registration) do
          create(:renewing_registration, :has_required_data, finance_details: build(:finance_details, :has_required_data))
        end

        before do
          # Add the same payment to both registrations
          registration.finance_details.payments << payment
          registration.finance_details.update_balance
          registration.save!

          # Create a clone of the payment with the same govpay_id
          clone_payment = build(:payment, govpay_id: govpay_id)
          transient_registration.finance_details.payments << clone_payment
          transient_registration.finance_details.update_balance
          transient_registration.save!
        end

        it "returns the registration (prioritizes non-transient registrations)" do
          expect(run_service).to eq(registration)
        end
      end
    end
  end
end
