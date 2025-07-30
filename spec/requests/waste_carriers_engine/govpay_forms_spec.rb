# frozen_string_literal: true

require "webmock/rspec"
require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "GovpayForms" do
    let(:govpay_host) { "https://publicapi.payments.service.gov.uk" }
    let(:token) { transient_registration[:token] }
    let(:order) { transient_registration.finance_details.orders.first }
    let(:order_key) { "#{Rails.configuration.govpay_merchant_code}^#{order.order_code}" }

    before do
      allow(Rails.configuration).to receive(:govpay_merchant_code).and_return("some_merchant_code")
      allow(Airbrake).to receive(:notify)
    end

    describe "#new" do
      let(:transient_registration) do
        create(:renewing_registration,
               :has_required_data,
               :has_addresses,
               :has_conviction_search_result,
               :has_key_people,
               workflow_state: "govpay_form",
               workflow_history: ["payment_summary_form"])
      end

      before do
        allow(GovpayPaymentService).to receive(:new).and_call_original

        stub_request(:any, /.*#{govpay_host}.*/).to_return(
          status: 200,
          body: File.read("./spec/fixtures/files/govpay/get_payment_response_created.json")
        )
      end

      it "creates a new finance_details" do
        expect { get new_govpay_form_path(token) }
          .to change { transient_registration.reload.finance_details }.from(nil)
      end

      it "creates a payment" do
        expect { get new_govpay_form_path(token) }
          .to change { transient_registration.reload.finance_details&.payments&.count }.to(1)
      end

      it "redirects to govpay" do
        get new_govpay_form_path(token)
        expect(response.location).to include("https://www.payments.service.gov.uk")
      end

      it "populates govpay_id on the order" do
        get new_govpay_form_path(token)
        expect(transient_registration.reload.finance_details.orders[0].govpay_id).to be_present
      end

      # Guard against page reloads
      context "when the govpay form is reloaded" do
        before do
          get new_govpay_form_path(token)
          get new_govpay_form_path(token)
        end

        it "calls the Gov.UK Pay API only once" do
          expect(GovpayPaymentService).to have_received(:new).exactly(:once)
        end
      end

      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration,
                 :has_addresses,
                 contact_email: "bar.baz@example.com",
                 workflow_state: "govpay_form",
                 temp_cards: 2)
        end

        it "creates a new finance_details" do
          expect { get new_govpay_form_path(token) }.to change { transient_registration.reload.finance_details }.from(nil)
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
      let(:govpay_host) { "https://publicapi.payments.service.gov.uk" }
      let(:payment_service) { instance_double(GovpayPaymentService) }
      let(:payment_details_service) { instance_double(GovpayPaymentDetailsService) }
      let(:transient_registration) do
        create(:renewing_registration, :has_pending_govpay_status,
               workflow_state: "govpay_form",
               workflow_history: ["payment_summary_form"])
      end

      before do
        allow(Rails.configuration).to receive(:govpay_url).and_return(govpay_host)
        allow(GovpayPaymentService).to receive(:new).and_return(payment_service)
        allow(payment_service).to receive(:prepare_for_payment)
        allow(GovpayPaymentDetailsService).to receive(:new).and_return(payment_details_service)
        allow(payment_details_service).to receive(:govpay_payment_status).and_return(govpay_status)

        transient_registration

        # transient_registration.prepare_for_payment(:govpay)
      end

      context "when govpay status is success" do
        let(:govpay_status) { Payment::STATUS_SUCCESS }

        context "when the payment_uuid is valid and the balance is paid" do

          # The payment used to be created on the callback; it is now created after the original govpay call
          it "does not add a new payment to the registration" do
            expect { get payment_callback_govpay_forms_path(token, order.payment_uuid) }
              .not_to change { transient_registration.reload.finance_details.payments.count }
          end

          it "redirects to renewal_complete_form" do
            get payment_callback_govpay_forms_path(token, order.payment_uuid)

            expect(response).to redirect_to(new_renewal_complete_form_path(token))
          end

          it "is idempotent" do
            get payment_callback_govpay_forms_path(token, order.payment_uuid)
            expect { get payment_callback_govpay_forms_path(token, order.payment_uuid) }.not_to change(order, :reload)
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

          it "redirects to payment_summary_form" do
            expect(response).to redirect_to(new_payment_summary_form_path(token))
          end

          it "notifies Airbrake" do
            expect(Airbrake)
              .to have_received(:notify)
              .with("Invalid Govpay response: Cannot find matching order", { payment_uuid: "invalid_uuid" })
          end
        end
      end

      context "with pending govpay statuses" do

        RSpec.shared_examples "payment is pending" do

          context "when the payment uuid is valid" do
            # The payment used to be created on the callback; it is now created after the original govpay call
            it "does not create a payment" do
              expect { get payment_callback_govpay_forms_path(token, order.payment_uuid) }
                .not_to change { transient_registration.reload.finance_details.payments.count }
            end

            it "redirects to renewal_received_pending_govpay_payment_form" do
              get payment_callback_govpay_forms_path(token, order.payment_uuid)
              expect(response).to redirect_to(new_renewal_received_pending_govpay_payment_form_path(token))
            end
          end

          context "when the payment uuid is invalid" do
            before { order.update!(govpay_id: nil) }

            it "redirects to payment_summary_form" do
              get payment_callback_govpay_forms_path(token, "invalid_payment_uuid")
              expect(response).to redirect_to(new_payment_summary_form_path(token))
            end
          end
        end

        context "when govpay status is created" do
          let(:govpay_status) { Payment::STATUS_CREATED }

          it_behaves_like "payment is pending"
        end

        context "when govpay status is started" do
          let(:govpay_status) { Payment::STATUS_STARTED }

          it_behaves_like "payment is pending"
        end

        context "when govpay status is submitted" do
          let(:govpay_status) { Payment::STATUS_SUBMITTED }

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
          let(:govpay_status) { Payment::STATUS_CANCELLED }

          it_behaves_like "payment is unsuccessful but no error"
        end

        context "with failure status" do
          let(:govpay_status) { Payment::STATUS_FAILED }

          it_behaves_like "payment is unsuccessful but no error"
        end

        context "with an error status" do
          let(:govpay_status) { "not_found" }

          it_behaves_like "payment is unsuccessful with an error"
        end
      end

      context "with an invalid success status" do
        before { allow(GovpayValidatorService).to receive(:valid_govpay_status?).and_return(false) }

        let(:govpay_status) { Payment::STATUS_SUCCESS }

        it_behaves_like "payment is unsuccessful with an error"
      end

      context "with an invalid failure status" do
        before { allow(GovpayValidatorService).to receive(:valid_govpay_status?).and_return(false) }

        let(:govpay_status) { Payment::STATUS_CANCELLED }

        it_behaves_like "payment is unsuccessful with an error"
      end
    end
  end
end
