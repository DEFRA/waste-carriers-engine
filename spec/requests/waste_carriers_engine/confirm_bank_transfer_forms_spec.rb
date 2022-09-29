# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "ConfirmBankTransferForms", type: :request do
    include_examples "GET locked-in form", "confirm_bank_transfer_form"

    describe "GET new_confirm_bank_transfer_form" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }

        before do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_unpaid_balance,
                   account_email: user.email,
                   workflow_state: "confirm_bank_transfer_form")
          end

          it "creates a new order" do
            get new_confirm_bank_transfer_form_path(transient_registration.token)

            expect(transient_registration.reload.finance_details.orders.count).to eq(1)
          end

          context "when the transient_registration is a new registration" do
            let(:transient_registration) do
              create(:new_registration,
                     contact_email: user.email,
                     workflow_state: "confirm_bank_transfer_form",
                     temp_cards: 2)
            end

            it "creates a new order" do
              get new_confirm_bank_transfer_form_path(transient_registration.token)

              expect(transient_registration.reload.finance_details.orders.count).to eq(1)
            end
          end

          context "when a worldpay order already exists" do
            before do
              transient_registration.prepare_for_payment(:worldpay, user)
              transient_registration.finance_details.orders.first.world_pay_status = "CANCELLED"
            end

            it "replaces the old order and does not increase the order count" do
              old_order_count = transient_registration.finance_details.orders.count

              get new_confirm_bank_transfer_form_path(transient_registration.token)

              expect(transient_registration.reload.finance_details.orders.first.world_pay_status).to be_nil
              expect(transient_registration.reload.finance_details.orders.count).to eq(old_order_count)
            end
          end
        end
      end
    end

    include_examples "POST without params form", "confirm_bank_transfer_form"

    describe "POST new_confirm_bank_transfer_form" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }

        before do
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
              transient_registration.update_attributes(workflow_state: :confirm_bank_transfer_form)
            end

            context "when the request is successful" do
              it "updates the transient registration metadata attributes from application configuration" do
                allow(Rails.configuration).to receive(:metadata_route).and_return("ASSISTED_DIGITAL")

                expect(transient_registration.reload.metaData.route).to be_nil

                post_form_with_params(:confirm_bank_transfer_form, transient_registration.token)

                expect(transient_registration.reload.metaData.route).to eq("ASSISTED_DIGITAL")
              end
            end
          end
        end
      end
    end
  end
end
