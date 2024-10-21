# frozen_string_literal: true

module WasteCarriersEngine
  RSpec.shared_examples "build finance details" do
    describe "#run" do

      let(:payment_method) { :govpay }
      let(:finance_details) { transient_registration.finance_details }
      let(:order) { finance_details.orders.last }

      it "creates a new order" do
        expect { run_service }.to change { finance_details.orders.length }.to 1
      end

      it "has a valid order_id" do
        Timecop.freeze(Time.new(2018, 1, 1)) do
          run_service
          expect(order[:order_id]).to eq("1514764800")
        end
      end

      it "has a matching order_id and order_code" do
        run_service
        expect(order[:order_id]).to eq(order[:order_code])
      end

      it "has the correct updated_by_user" do
        run_service
        expect(order.updated_by_user).to eq(transient_registration.contact_email)
      end

      it "updates the date_created" do
        Timecop.freeze(Time.new(2004, 8, 15, 16, 23, 42)) do
          run_service
          expect(order.date_created).to eq(Time.new(2004, 8, 15, 16, 23, 42))
        end
      end

      it "updates the date_last_updated" do
        Timecop.freeze(Time.new(2004, 8, 15, 16, 23, 42)) do
          run_service
          expect(order.date_last_updated).to eq(Time.new(2004, 8, 15, 16, 23, 42))
        end
      end

      context "when it is a govpay order" do
        let(:payment_method) { :govpay }

        before { run_service }

        it "has the correct payment_method" do
          expect(order.payment_method).to eq("ONLINE")
        end
      end

      context "when it is a bank transfer order" do
        let(:payment_method) { :bank_transfer }

        before { run_service }

        it "has the correct payment_method" do
          expect(order.payment_method).to eq("OFFLINE")
        end

        it "has the correct merchant_id" do
          expect(order.merchant_id).to be_nil
        end

        it "has the correct govpay_status" do
          expect(order.govpay_status).to be_nil
        end
      end

      context "when an order already exists" do
        before { finance_details.orders << build(:order) }

        it { expect { run_service }.not_to(change { transient_registration.finance_details.orders }) }
      end
    end
  end
end
