require "rails_helper"

RSpec.describe "WorldpayForms", type: :request do
  before do
    allow(Rails.configuration).to receive(:worldpay_admin_code).and_return("ADMIN_CODE")
    allow(Rails.configuration).to receive(:worldpay_merchantcode).and_return("MERCHANTCODE")
    allow(Rails.configuration).to receive(:worldpay_macsecret).and_return("5r2zsonhn2t69s1q9jsub90l0ljrs59r")
  end

  context "when a valid user is signed in" do
    let(:user) { create(:user) }
    before(:each) do
      sign_in(user)
    end

    context "when a valid transient registration exists" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               :has_addresses,
               account_email: user.email,
               workflow_state: "worldpay_form")
      end
      let(:reg_id) { transient_registration[:reg_identifier] }

      describe "#new" do
        it "redirects to worldpay" do
          VCR.use_cassette("worldpay_redirect") do
            get new_worldpay_form_path(reg_id)
            expect(response.location).to include("https://secure-test.worldpay.com")
          end
        end

        it "creates a new finance_details" do
          VCR.use_cassette("worldpay_redirect") do
            get new_worldpay_form_path(reg_id)
            expect(transient_registration.reload.finance_details).to_not eq(nil)
          end
        end

        context "when there is an error setting up the worldpay url" do
          before do
            allow_any_instance_of(WorldpayService).to receive(:prepare_for_payment).and_return(:error)
          end

          it "redirects to payment_summary_form" do
            get new_worldpay_form_path(reg_id)
            expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
          end
        end
      end

      describe "#success" do
        before do
          # We need to set a specific time so we know what order code to expect
          Timecop.freeze(Time.new(2018, 1, 1)) do
            FinanceDetails.new_finance_details(transient_registration)
            Payment.new_from_worldpay(order)
          end
        end

        let(:order) do
          transient_registration.finance_details.orders.first
        end

        let(:params) do
          {
            orderKey: "#{Rails.configuration.worldpay_admin_code}^#{Rails.configuration.worldpay_merchantcode}^#{order.order_code}",
            paymentStatus: "AUTHORISED",
            paymentAmount: order.total_amount,
            paymentCurrency: "GBP",
            mac: "2a8d84f7642a44d53464329f65bc00c8",
            source: "WP",
            reg_identifier: reg_id
          }
        end

        context "when the params are valid" do
          it "redirects to renewal_complete_form" do
            get success_worldpay_forms_path(reg_id), params
            expect(response).to redirect_to(new_renewal_complete_form_path(reg_id))
          end

          it "updates the payment status" do
            get success_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first.world_pay_payment_status).to eq("AUTHORISED")
          end

          it "updates the order status" do
            get success_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.orders.first.world_pay_status).to eq("AUTHORISED")
          end

          it "updates the balance" do
            get success_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.balance).to eq(0)
          end

          context "when it has been flagged for conviction checks" do
            before do
              transient_registration.update_attributes(declared_convictions: true)
            end

            it "redirects to renewal_received_form" do
              get success_worldpay_forms_path(reg_id), params
              expect(response).to redirect_to(new_renewal_received_form_path(reg_id))
            end
          end
        end

        context "when the orderKey doesn't match an existing order" do
          before do
            params[:orderKey] = "0123456789"
          end

          it "redirects to payment_summary_form" do
            get success_worldpay_forms_path(reg_id), params
            expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
          end

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get success_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end

        context "when the orderKey is in the wrong format" do
          before do
            params[:orderKey] = "foo#{order.order_code}"
            # Change the MAC param to still be valid as this relies on the orderKey
            params[:mac] = "b6a6743451bf925ecb564da496413ff6"
          end

          it "redirects to payment_summary_form" do
            get success_worldpay_forms_path(reg_id), params
            expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
          end

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get success_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end

        context "when the paymentStatus is invalid" do
          before do
            params[:paymentStatus] = "foo"
            # Change the MAC param to still be valid as this relies on the paymentStatus
            params[:mac] = "df56c36305b6360db3f9178fd4683073"
          end

          it "redirects to payment_summary_form" do
            get success_worldpay_forms_path(reg_id), params
            expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
          end

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get success_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end

        context "when the paymentAmount is invalid" do
          before do
            params[:paymentAmount] = 42
            # Change the MAC param to still be valid as this relies on the paymentAmount
            params[:mac] = "926883e7cf68b253503446d9cc50f60d"
          end

          it "redirects to payment_summary_form" do
            get success_worldpay_forms_path(reg_id), params
            expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
          end

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get success_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end

        context "when the paymentCurrency is invalid" do
          before do
            params[:paymentCurrency] = "foo"
            # Change the MAC param to still be valid as this relies on the paymentCurrency
            params[:mac] = "8bbd0a859b749c1d4e22198c166c632f"
          end

          it "redirects to payment_summary_form" do
            get success_worldpay_forms_path(reg_id), params
            expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
          end

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get success_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end

        context "when the mac is invalid" do
          before do
            params[:mac] = "foo"
          end

          it "redirects to payment_summary_form" do
            get success_worldpay_forms_path(reg_id), params
            expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
          end

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get success_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end

        context "when the source is invalid" do
          before do
            params[:source] = "foo"
          end

          it "redirects to payment_summary_form" do
            get success_worldpay_forms_path(reg_id), params
            expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
          end

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get success_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end
      end

      describe "#failure" do
        before do
          # We need to set a specific time so we know what order code to expect
          Timecop.freeze(Time.new(2018, 1, 2)) do
            FinanceDetails.new_finance_details(transient_registration)
            Payment.new_from_worldpay(order)
          end
        end

        let(:order) do
          transient_registration.finance_details.orders.first
        end

        let(:params) do
          {
            orderKey: "#{Rails.configuration.worldpay_admin_code}^#{Rails.configuration.worldpay_merchantcode}^#{order.order_code}",
            paymentStatus: "REFUSED",
            paymentAmount: order.total_amount,
            paymentCurrency: "GBP",
            mac: "8e4496d6db44f2de4de0d3acfd372c47",
            source: "WP",
            reg_identifier: reg_id
          }
        end

        it "redirects to payment_summary_form" do
          get failure_worldpay_forms_path(reg_id), params
          expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
        end

        it "updates the payment status" do
          get failure_worldpay_forms_path(reg_id), params
          expect(transient_registration.reload.finance_details.payments.first.world_pay_payment_status).to eq("REFUSED")
        end

        it "updates the order status" do
          get failure_worldpay_forms_path(reg_id), params
          expect(transient_registration.reload.finance_details.orders.first.world_pay_status).to eq("REFUSED")
        end

        it "does not update the balance" do
          unmodified_balance = transient_registration.finance_details.balance
          get success_worldpay_forms_path(reg_id), params
          expect(transient_registration.reload.finance_details.balance).to eq(unmodified_balance)
        end

        context "when the orderKey doesn't match an existing order" do
          before do
            params[:orderKey] = "0123456789"
          end

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get failure_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end

        context "when the orderKey is in the wrong format" do
          before do
            params[:orderKey] = "foo#{order.order_code}"
            # Change the MAC param to still be valid as this relies on the orderKey
            params[:mac] = "ccebed8b4f3b53a9ed6a9e27b0a353a9"
          end

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get failure_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end

        context "when the paymentStatus is invalid" do
          before do
            params[:paymentStatus] = "foo"
            # Change the MAC param to still be valid as this relies on the paymentStatus
            params[:mac] = "796daa4118411ff7a901883f5628a9be"
          end

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get failure_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end

        context "when the paymentAmount is invalid" do
          before do
            params[:paymentAmount] = 42
            # Change the MAC param to still be valid as this relies on the paymentAmount
            params[:mac] = "05d4ef2cb316d3ce6c7402863f65be7f"
          end

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get failure_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end

        context "when the paymentCurrency is invalid" do
          before do
            params[:paymentCurrency] = "foo"
            # Change the MAC param to still be valid as this relies on the paymentCurrency
            params[:mac] = "29a27f59b3695e82487e1d4f827c364b"
          end

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get failure_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end

        context "when the mac is invalid" do
          before do
            params[:mac] = "foo"
          end

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get failure_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end

        context "when the source is invalid" do
          before do
            params[:source] = "foo"
          end

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get failure_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end
      end
    end
  end
end
