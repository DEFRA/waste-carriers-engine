# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "BankTransferForms", type: :request do
    include_examples "GET locked-in form", "bank_transfer_form"

    describe "GET new_bank_transfer_form" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_unpaid_balance,
                   account_email: user.email,
                   workflow_state: "bank_transfer_form")
          end

          it "creates a new order" do
            get new_bank_transfer_form_path(transient_registration[:reg_identifier])
            expect(transient_registration.reload.finance_details.orders.count).to eq(1)
          end

          context "when a worldpay order already exists" do
            before do
              transient_registration.prepare_for_payment(:worldpay, user)
              transient_registration.finance_details.orders.first.world_pay_status = "CANCELLED"
            end

            it "replaces the old order" do
              get new_bank_transfer_form_path(transient_registration[:reg_identifier])
              expect(transient_registration.reload.finance_details.orders.first.world_pay_status).to eq(nil)
            end

            it "does not increase the order count" do
              old_order_count = transient_registration.finance_details.orders.count
              get new_bank_transfer_form_path(transient_registration[:reg_identifier])
              expect(transient_registration.reload.finance_details.orders.count).to eq(old_order_count)
            end
          end
        end
      end
    end

    include_examples "POST without params form", "bank_transfer_form"

    describe "POST new_bank_transfer_form" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }

        before(:each) do
          sign_in(user)
        end

        context "when a renewal is in progress" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_addresses,
                   :has_key_people,
                   :has_unpaid_balance,
                   account_email: user.email)
          end

          context "when the workflow_state matches the requested form" do
            before do
              transient_registration.update_attributes(workflow_state: :bank_transfer_form)
            end

            context "when the request is successful" do
              it "updates the transient registration metadata attributes from application configuration" do
                allow(Rails.configuration).to receive(:metadata_route).and_return("ASSISTED_DIGITAL")

                expect(transient_registration.reload.metaData.route).to be_nil

                post_form_with_params(:bank_transfer_form, reg_identifier: transient_registration.reg_identifier)

                expect(transient_registration.reload.metaData.route).to eq("ASSISTED_DIGITAL")
              end
            end
          end
        end
      end
    end

    describe "GET back_bank_transfer_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_unpaid_balance,
                   account_email: user.email,
                   workflow_state: "bank_transfer_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_bank_transfer_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the payment_summary form" do
              get back_bank_transfer_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_payment_summary_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_unpaid_balance,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_bank_transfer_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get back_bank_transfer_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
            end
          end
        end
      end
    end
  end
end
