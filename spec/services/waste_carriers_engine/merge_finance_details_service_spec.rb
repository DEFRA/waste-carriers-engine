# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe MergeFinanceDetailsService do
    describe ".call" do
      let(:transient_registration) do
        create(
          :renewing_registration,
          :has_required_data,
          :has_addresses,
          :has_key_people,
          :has_paid_order_with_two_orders,
          company_name: "FooBiz",
          workflow_state: "renewal_complete_form"
        )
      end
      let(:registration) { Registration.where(reg_identifier: transient_registration.reg_identifier).first }

      let(:new_order) { transient_registration.reload.finance_details.orders.first }
      let(:new_payment) { transient_registration.reload.finance_details.payments.first }
      let(:updated_balance) { transient_registration.reload.finance_details.balance }

      before do
        described_class.call(registration: registration, transient_registration: transient_registration)
      end

      it "merges orders from transient registration into registration" do
        expect(registration.finance_details.orders).to include(new_order)
      end

      it "merges payments from transient registration into registration" do
        expect(registration.finance_details.payments).to include(new_payment)
      end

      it "updates the balance of the registration’s finance details" do
        expect(registration.finance_details.reload.balance).to eq(updated_balance)
      end
    end
  end
end
