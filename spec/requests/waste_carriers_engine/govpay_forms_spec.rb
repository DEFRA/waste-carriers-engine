# frozen_string_literal: true

require "webmock/rspec"
require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "GovpayForms", type: :request do
    let(:govpay_host) { "https://publicapi.payments.service.gov.uk" }
    let(:order) { transient_registration.finance_details.orders.first }
    let(:order_key) { "#{Rails.configuration.govpay_merchant_code}^#{order.order_code}" }

    before do
      allow(Rails.configuration).to receive(:govpay_url).and_return(govpay_host)
      allow(Rails.configuration).to receive(:govpay_merchant_code).and_return("some_merchant_code")
      allow(Rails.configuration).to receive(:govpay_api_token).and_return("some_token")
    end

    # TODO: Remove this when the feature flag is no longer required
    # before { allow(WasteCarriersEngine::FeatureToggle).to receive(:active?).with(:govpay_payments).and_return(true) }

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
            before do
              allow_any_instance_of(GovpayPaymentService).to receive(:prepare_for_payment).and_return(:error)
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
            allow(WasteCarriersEngine::FeatureToggle).to receive(:active?).with(:govpay_payments).and_return(true)
            allow(WasteCarriersEngine::FeatureToggle).to receive(:active?).with(:use_extended_grace_window).and_return(true)
            allow(Rails.configuration).to receive(:govpay_url).and_return(govpay_host)
            allow(Rails.configuration).to receive(:metadata_route).and_return("ASSISTED_DIGITAL")
            stub_request(:any, %r{.*#{govpay_host}/payments}).to_return(
              status: 200,
              body: File.read("./spec/fixtures/files/govpay/get_payment_response_#{govpay_status}.json")
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

              it "updates the metadata route" do
                expect(transient_registration.reload.metaData.route).to be_nil

                get payment_callback_govpay_forms_path(token, order.payment_uuid)

                expect(transient_registration.reload.metaData.route).to eq("ASSISTED_DIGITAL")
              end

              it "is idempotent" do
                expect do
                  get payment_callback_govpay_forms_path(token, order.payment_uuid)
                  get payment_callback_govpay_forms_path(token, order.payment_uuid)
                  transient_registration.reload
                end.to change { transient_registration.finance_details.payments.count }.from(0).to(1)
              end

              context "when it has been flagged for conviction checks" do
                before { transient_registration.conviction_sign_offs = [build(:conviction_sign_off)] }

                it "updates the transient registration metadata attributes from application configuration" do
                  expect(transient_registration.reload.metaData.route).to be_nil

                  get payment_callback_govpay_forms_path(token, order.payment_uuid)

                  expect(transient_registration.reload.metaData.route).to eq("ASSISTED_DIGITAL")
                end

                it "redirects to renewal_received_pending_conviction_form" do
                  get payment_callback_govpay_forms_path(token, order.payment_uuid)

                  expect(response).to redirect_to(new_renewal_received_pending_conviction_form_path(token))
                end

                context "when the mailer fails" do
                  before do
                    allow(Rails.configuration.action_mailer).to receive(:raise_delivery_errors).and_return(true)
                    allow_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now).and_raise(StandardError)
                  end

                  it "does not raise an error" do
                    expect { get payment_callback_govpay_forms_path(token, order.payment_uuid) }.to_not raise_error
                  end
                end
              end
            end

            context "when the payment uuid is invalid" do
              before do
                stub_request(:any, %r{.*#{govpay_host}/payments}).to_return(
                  status: 200,
                  body: File.read("./spec/fixtures/files/govpay/get_payment_response_not_found.json")
                )
              end

              it "does not create a payment" do
                get payment_callback_govpay_forms_path(token, "invalid_uuid")
                expect(transient_registration.reload.finance_details.payments.first).to be_nil
              end

              it "redirects to payment_summary_form" do
                get payment_callback_govpay_forms_path(token, "invalid_uuid")
                expect(response).to redirect_to(new_payment_summary_form_path(token))
              end
            end
          end

          context "for pending govpay statuses" do

            RSpec.shared_examples "payment is pending" do

              context "when the payment uuid is valid" do
                before do
                  allow_any_instance_of(RenewingRegistration).to receive(:pending_online_payment?).and_return(true)
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

          context "for unsuccessful govpay statuses" do

            RSpec.shared_examples "payment is unsuccessful" do

              context "when the payment uuid is valid" do
                it "redirects to payment_summary_form" do
                  get payment_callback_govpay_forms_path(token, order.payment_uuid)
                  expect(response).to redirect_to(new_payment_summary_form_path(token))
                end
              end

              context "when the payment uuid is invalid" do
                it "redirects to payment_summary_form" do
                  get payment_callback_govpay_forms_path(token, "invalid_payment_uuid")
                  expect(response).to redirect_to(new_payment_summary_form_path(token))
                end
              end
            end

            context "when govpay status is cancel" do
              let(:govpay_status) { "cancelled" }
              it_behaves_like "payment is unsuccessful"
            end

            context "failure" do
              let(:govpay_status) { "failure" }
              it_behaves_like "payment is unsuccessful"
            end

            context "error" do
              let(:govpay_status) { "not_found" }
              it_behaves_like "payment is unsuccessful"
            end
          end

          context "for an invalid success status" do
            before { allow(GovpayValidatorService).to receive(:valid_govpay_status?).and_return(false) }

            let(:govpay_status) { "success" }
            it_behaves_like "payment is unsuccessful"
          end

          context "for an invalid failure status" do
            before { allow(GovpayValidatorService).to receive(:valid_govpay_status?).and_return(false) }

            let(:govpay_status) { "cancelled" }
            it_behaves_like "payment is unsuccessful"
          end
        end
      end
    end
  end
end
