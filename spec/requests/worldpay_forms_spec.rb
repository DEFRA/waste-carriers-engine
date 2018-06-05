require "rails_helper"

RSpec.describe "WorldpayForms", type: :request do

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
          FinanceDetails.new_finance_details(transient_registration)
          Payment.new_from_worldpay(order)
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
            mac: "5r2zsonhn2t69s1q9jsub90l0ljrs59r",
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
          before { params[:orderKey] = "0123456789" }

          it "redirects to payment_summary_form" do
            get success_worldpay_forms_path(reg_id), params
            expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
          end
        end

        context "when the orderKey is in the wrong format" do
          before { params[:orderKey] = "foo#{order.order_code}" }

          it "redirects to payment_summary_form" do
            get success_worldpay_forms_path(reg_id), params
            expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
          end
        end

        context "when the paymentStatus is invalid" do
          before { params[:paymentStatus] = "foo" }

          it "redirects to payment_summary_form" do
            get success_worldpay_forms_path(reg_id), params
            expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
          end
        end

        context "when the paymentAmount is invalid" do
          before { params[:paymentAmount] = 42 }

          it "redirects to payment_summary_form" do
            get success_worldpay_forms_path(reg_id), params
            expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
          end
        end

        context "when the paymentCurrency is invalid" do
          before { params[:paymentCurrency] = "foo" }

          it "redirects to payment_summary_form" do
            get success_worldpay_forms_path(reg_id), params
            expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
          end
        end

        context "when the source is invalid" do
          before { params[:source] = "foo" }

          it "redirects to payment_summary_form" do
            get success_worldpay_forms_path(reg_id), params
            expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
          end
        end
      end

      describe "#failure" do
        before do
          FinanceDetails.new_finance_details(transient_registration)
          Payment.new_from_worldpay(order)
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
            mac: "5r2zsonhn2t69s1q9jsub90l0ljrs59r",
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

        it "does not update the balance" do
          unmodified_balance = transient_registration.finance_details.balance
          get success_worldpay_forms_path(reg_id), params
          expect(transient_registration.reload.finance_details.balance).to eq(unmodified_balance)
        end

        context "when the orderKey doesn't match an existing order" do
          before { params[:orderKey] = "0123456789" }

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get failure_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end

        context "when the orderKey is in the wrong format" do
          before { params[:orderKey] = "foo#{order.order_code}" }

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get failure_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end

        context "when the paymentStatus is invalid" do
          before { params[:paymentStatus] = "foo" }

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get failure_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end

        context "when the paymentAmount is invalid" do
          before { params[:paymentAmount] = 42 }

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get failure_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end

        context "when the paymentCurrency is invalid" do
          before { params[:paymentCurrency] = "foo" }

          it "does not update the payment" do
            unmodified_payment = transient_registration.finance_details.payments.first
            get failure_worldpay_forms_path(reg_id), params
            expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
          end
        end

        context "when the source is invalid" do
          before { params[:source] = "foo" }

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
