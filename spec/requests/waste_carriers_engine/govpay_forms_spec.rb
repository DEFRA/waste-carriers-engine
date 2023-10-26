# frozen_string_literal: true

require "webmock/rspec"
require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "GovpayForms" do
    let(:govpay_host) { "https://publicapi.payments.service.gov.uk" }
    let(:order) { transient_registration.finance_details.orders.first }
    let(:order_key) { "#{Rails.configuration.govpay_merchant_code}^#{order.order_code}" }

    before do
      allow(Rails.configuration).to receive(:govpay_merchant_code).and_return("some_merchant_code")

      # set these variables in govpay configuration
      DefraRubyGovpay.configure do |config|
        config.govpay_url = govpay_host
        config.govpay_front_office_api_token = "some_token"
        config.govpay_back_office_api_token = "some_token"
      end

      stub_const("DefraRubyGovpayAPI", DefraRubyGovpay::API.new)

      allow(Airbrake).to receive(:notify)
    end

    context "when a valid user is signed in" do
      let(:user) { create(:user) }

      before do
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
                 workflow_state: "govpay_form",
                 workflow_history: ["payment_summary_form"])
        end
        let(:order) { transient_registration.finance_details.orders.first }
        let(:token) { transient_registration[:token] }

        describe "#new" do

          before do
            stub_request(:any, /.*#{govpay_host}.*/).to_return(
              status: 200,
              body: File.read("./spec/fixtures/files/govpay/get_payment_response_created.json")
            )
          end

          it "creates a new finance_details" do
            get new_govpay_form_path(token)
            expect(transient_registration.reload.finance_details).to be_present
          end

          it "redirects to govpay" do
            get new_govpay_form_path(token)
            expect(response.location).to include("https://www.payments.service.gov.uk")
          end

          it "populates govpay_id on the order" do
            get new_govpay_form_path(token)
            expect(transient_registration.reload.finance_details.orders[0].govpay_id).to be_present
          end

          context "when the transient_registration is a new registration" do
            let(:transient_registration) do
              create(:new_registration,
                     :has_addresses,
                     contact_email: user.email,
                     workflow_state: "govpay_form",
                     temp_cards: 2)
            end

            it "creates a new finance_details" do
              get new_govpay_form_path(token)
              expect(transient_registration.reload.finance_details).to be_present
            end
          end

          context "when there is an error setting up the govpay url" do
            let(:govpay_service) { instance_double(GovpayPaymentService) }

            before do
              allow(GovpayPaymentService).to receive(:new).and_return(govpay_service)
              allow(govpay_service).to receive(:prepare_for_payment).and_return(:error)
            end

            it "redirects to payment_summary_form" do
              get new_govpay_form_path(token)
              expect(response).to redirect_to(new_payment_summary_form_path(token))
            end
          end
        end

        describe "#payment_callback" do
          let(:govpay_host) { "https://publicapi.payments.service.gov.uk/v1" }

          before do
            allow(Rails.configuration).to receive(:govpay_url).and_return(govpay_host)
            stub_request(:any, %r{.*#{govpay_host}/payments}).to_return(
              status: 200,
              body: file_fixture("govpay/get_payment_response_#{govpay_status}.json")
            )
            transient_registration.prepare_for_payment(:govpay, user)
            GovpayPaymentService.new(transient_registration, order, user).prepare_for_payment
          end

          context "when govpay status is success" do
            let(:govpay_status) { "success" }

            context "when the payment_uuid is valid and the balance is paid" do

              it "adds a new payment to the registration" do
                expect { get payment_callback_govpay_forms_path(token, order.payment_uuid) }
                  .to change { transient_registration.reload.finance_details.payments.count }.from(0).to(1)
              end

              it "redirects to renewal_complete_form" do
                get payment_callback_govpay_forms_path(token, order.payment_uuid)

                expect(response).to redirect_to(new_renewal_complete_form_path(token))
              end

              it "is idempotent" do
                expect do
                  get payment_callback_govpay_forms_path(token, order.payment_uuid)
                  get payment_callback_govpay_forms_path(token, order.payment_uuid)
                  transient_registration.reload
                end.to change { transient_registration.finance_details.payments.count }.from(0).to(1)
              end

              it "does not log an error" do
                get payment_callback_govpay_forms_path(token, order.payment_uuid)

                expect(Airbrake).not_to have_received(:notify)
              end

              context "when it has been flagged for conviction checks" do
                before { transient_registration.conviction_sign_offs = [build(:conviction_sign_off)] }

                it "redirects to renewal_received_pending_conviction_form" do
                  get payment_callback_govpay_forms_path(token, order.payment_uuid)

                  expect(response).to redirect_to(new_renewal_received_pending_conviction_form_path(token))
                end
              end
            end

            context "when the payment uuid is invalid" do
              before do
                stub_request(:any, %r{.*#{govpay_host}/payments}).to_return(
                  status: 200,
                  body: File.read("./spec/fixtures/files/govpay/get_payment_response_not_found.json")
                )

                get payment_callback_govpay_forms_path(token, "invalid_uuid")
              end

              it "does not create a payment" do
                expect(transient_registration.reload.finance_details.payments.first).to be_nil
              end

              it "redirects to payment_summary_form" do
                expect(response).to redirect_to(new_payment_summary_form_path(token))
              end

              it "notifies Airbrake" do
                expect(Airbrake)
                  .to have_received(:notify)
                  .with("Govpay callback error: Invalid payment uuid", { payment_uuid: "invalid_uuid" })
              end
            end
          end

          context "with pending govpay statuses" do

            RSpec.shared_examples "payment is pending" do

              context "when the payment uuid is valid" do
                before do
                  order.update!(govpay_status: "created")
                end

                it "redirects to renewal_received_pending_govpay_payment_form" do
                  get payment_callback_govpay_forms_path(token, order.payment_uuid)
                  expect(response).to redirect_to(new_renewal_received_pending_govpay_payment_form_path(token))
                end
              end

              context "when the payment uuid is invalid" do
                it "redirects to payment_summary_form" do
                  get payment_callback_govpay_forms_path(token, "invalid_payment_uuid")
                  expect(response).to redirect_to(new_payment_summary_form_path(token))
                end
              end
            end

            context "when govpay status is created" do
              let(:govpay_status) { "created" }

              it_behaves_like "payment is pending"
            end

            context "when govpay status is submitted" do
              let(:govpay_status) { "submitted" }

              it_behaves_like "payment is pending"
            end
          end

          context "with unsuccessful govpay statuses" do

            RSpec.shared_examples "payment is unsuccessful but no error" do

              it "redirects to payment_summary_form" do
                get payment_callback_govpay_forms_path(token, order.payment_uuid)

                expect(response).to redirect_to(new_payment_summary_form_path(token))
              end

              it "does not log an error" do
                get payment_callback_govpay_forms_path(token, order.payment_uuid)

                expect(Airbrake).not_to have_received(:notify)
              end
            end

            RSpec.shared_examples "payment is unsuccessful with an error" do

              it "redirects to payment_summary_form" do
                get payment_callback_govpay_forms_path(token, order.payment_uuid)

                expect(response).to redirect_to(new_payment_summary_form_path(token))
              end

              it "logs an error" do
                get payment_callback_govpay_forms_path(token, order.payment_uuid)

                expect(Airbrake).to have_received(:notify).at_least(:once)
              end
            end

            context "with cancelled status" do
              let(:govpay_status) { "cancelled" }

              it_behaves_like "payment is unsuccessful but no error"
            end

            context "with failure status" do
              let(:govpay_status) { "failure" }

              it_behaves_like "payment is unsuccessful but no error"
            end

            context "with an error status" do
              let(:govpay_status) { "not_found" }

              it_behaves_like "payment is unsuccessful with an error"
            end
          end

          context "with an invalid success status" do
            before { allow(GovpayValidatorService).to receive(:valid_govpay_status?).and_return(false) }

            let(:govpay_status) { "success" }

            it_behaves_like "payment is unsuccessful with an error"
          end

          context "with an invalid failure status" do
            before { allow(GovpayValidatorService).to receive(:valid_govpay_status?).and_return(false) }

            let(:govpay_status) { "cancelled" }

            it_behaves_like "payment is unsuccessful with an error"
          end
        end
      end
    end
  end
end
