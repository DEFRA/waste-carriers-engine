# frozen_string_literal: true

require "webmock/rspec"
require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "WorldpayForms", type: :request do
    let(:host) { "https://secure-test.worldpay.com" }

    context "when a valid user is signed in" do
      let(:user) { create(:user) }
      before(:each) do
        sign_in(user)
      end

      context "when a valid transient registration exists" do
        let(:transient_registration) do
          create(:renewing_registration,
                 :has_required_data,
                 :has_addresses,
                 :has_conviction_search_result,
                 :has_key_people,
                 account_email: user.email,
                 workflow_state: "worldpay_form")
        end
        let(:token) { transient_registration[:token] }

        describe "#new" do
          before do
            stub_request(:any, /.*#{host}.*/).to_return(
              status: 200,
              body: File.read("./spec/fixtures/worldpay_redirect.xml")
            )
          end

          it "redirects to worldpay and creates a new finance_details" do
            get new_worldpay_form_path(token)

            expect(response.location).to include("https://hpp-sandbox.worldpay.com/")
            expect(transient_registration.reload.finance_details).to_not eq(nil)
          end

          context "when the transient_registration is a new registration" do
            let(:transient_registration) do
              create(:new_registration,
                     :has_addresses,
                     contact_email: user.email,
                     workflow_state: "worldpay_form",
                     temp_cards: 2)
            end

            it "creates a new finance_details" do
              get new_worldpay_form_path(token)
              expect(transient_registration.reload.finance_details).to_not eq(nil)
            end
          end

          context "when there is an error setting up the worldpay url" do
            before do
              allow_any_instance_of(WorldpayService).to receive(:prepare_for_payment).and_return(:error)
            end

            it "redirects to payment_summary_form" do
              get new_worldpay_form_path(token)
              expect(response).to redirect_to(new_payment_summary_form_path(token))
            end
          end
        end

        describe "#success" do
          before do
            transient_registration.prepare_for_payment(:worldpay, user)
          end

          let(:order) do
            transient_registration.finance_details.orders.first
          end

          let(:order_key) do
            "#{Rails.configuration.worldpay_admin_code}^#{Rails.configuration.worldpay_merchantcode}^#{order.order_code}"
          end

          let(:mac) do
            data = [
              order_key,
              order.total_amount,
              "GBP",
              "AUTHORISED",
              Rails.configuration.worldpay_macsecret
            ]

            Digest::MD5.hexdigest(data.join).to_s
          end

          let(:params) do
            {
              orderKey: order_key,
              token: token,
              paymentAmount: order.total_amount,
              paymentCurrency: "GBP",
              paymentStatus: "AUTHORISED",
              mac: mac
            }
          end

          context "when the params are valid and the balance is paid" do
            let(:params) do
              {
                orderKey: order_key,
                token: token,
                paymentAmount: order.total_amount,
                paymentCurrency: "GBP",
                paymentStatus: "AUTHORISED",
                mac: mac
              }
            end

            it "add a new payment to the registration, redirects to renewal_complete_form, updates the metadata route and is idempotent." do
              allow(Rails.configuration).to receive(:metadata_route).and_return("ASSISTED_DIGITAL")
              expected_payments_count = transient_registration.finance_details.payments.count + 1

              get success_worldpay_forms_path(token), params: params
              get success_worldpay_forms_path(token), params: params

              transient_registration.reload

              expect(response).to redirect_to(new_renewal_complete_form_path(token))
              expect(transient_registration.metaData.route).to eq("ASSISTED_DIGITAL")
              expect(transient_registration.finance_details.payments.count).to eq(expected_payments_count)
            end

            context "when it has been flagged for conviction checks" do
              before do
                transient_registration.conviction_sign_offs = [build(:conviction_sign_off)]
              end

              it "updates the transient registration metadata attributes from application configuration and redirects to renewal_received_pending_conviction_form" do
                allow(Rails.configuration).to receive(:metadata_route).and_return("ASSISTED_DIGITAL")

                expect(transient_registration.reload.metaData.route).to be_nil

                get success_worldpay_forms_path(token), params: params

                expect(transient_registration.reload.metaData.route).to eq("ASSISTED_DIGITAL")
                expect(response).to redirect_to(new_renewal_received_pending_conviction_form_path(token))
              end

              context "when the mailer fails" do
                before do
                  allow(Rails.configuration.action_mailer).to receive(:raise_delivery_errors).and_return(true)
                  allow_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now).and_raise(StandardError)
                end

                it "does not raise an error" do
                  expect { get success_worldpay_forms_path(token), params: params }.to_not raise_error
                end
              end
            end
          end

          context "when the params are invalid" do
            let(:params) do
              {
                orderKey: order_key,
                token: token,
                paymentAmount: order.total_amount,
                paymentCurrency: "GBP",
                paymentStatus: "AUTHORISED",
                mac: "FOO"
              }
            end

            it "redirects to payment_summary_form" do
              get success_worldpay_forms_path(token), params: params
              expect(response).to redirect_to(new_payment_summary_form_path(token))
            end
          end

          context "when the orderKey doesn't match an existing order" do
            before do
              params[:orderKey] = "0123456789"
            end

            it "does not update the payment and redirects to payment_summary_form" do
              unmodified_payment = transient_registration.finance_details.payments.first

              get success_worldpay_forms_path(token), params: params

              expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
              expect(response).to redirect_to(new_payment_summary_form_path(token))
            end
          end
        end

        describe "#pending" do
          before do
            transient_registration.prepare_for_payment(:worldpay, user)
          end

          let(:order) do
            transient_registration.finance_details.orders.first
          end

          let(:params) do
            {
              orderKey: "#{Rails.configuration.worldpay_admin_code}^#{Rails.configuration.worldpay_merchantcode}^#{order.order_code}",
              token: token
            }
          end

          context "when the params are valid" do
            before do
              allow_any_instance_of(WorldpayService).to receive(:valid_pending?).and_return(true)
              allow_any_instance_of(RenewingRegistration).to receive(:pending_worldpay_payment?).and_return(true)
            end

            it "redirects to renewal_received_pending_payment_form" do
              get pending_worldpay_forms_path(token), params: params
              expect(response).to redirect_to(new_renewal_received_pending_worldpay_payment_form_path(token))
            end
          end

          context "when the params are invalid" do
            before do
              allow_any_instance_of(WorldpayService).to receive(:valid_pending?).and_return(false)
            end

            it "redirects to payment_summary_form" do
              get pending_worldpay_forms_path(token), params: params
              expect(response).to redirect_to(new_payment_summary_form_path(token))
            end
          end
        end
      end
    end

    describe "#cancel" do
      it_should_behave_like "GET unsuccessful Worldpay response", :cancel
    end

    describe "#error" do
      it_should_behave_like "GET unsuccessful Worldpay response", :error
    end

    describe "#failure" do
      it_should_behave_like "GET unsuccessful Worldpay response", :failure
    end
  end
end
