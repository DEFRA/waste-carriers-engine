# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewalCompletionService do
    let(:transient_registration) do
      create(
        :renewing_registration,
        :has_required_data,
        :has_addresses,
        :has_key_people,
        :has_paid_order,
        company_name: "FooBiz",
        workflow_state: "renewal_complete_form"
      )
    end
    let(:registration) { Registration.where(reg_identifier: transient_registration.reg_identifier).first }

    let(:renewal_completion_service) { RenewalCompletionService.new(transient_registration) }

    before do
      # We have to run this block after the transient registration creation,
      # because it creates a new one as part of the has_required_data trait.
      # Hence we create the transient, which in turn creates the registration
      # and we then update it before each test
      registration.update_attributes!(
        finance_details: build(
          :finance_details,
          :has_outstanding_copy_card
        )
      )
    end

    describe "#complete_renewal" do
      context "when the renewal can be complete" do
        it "creates a new past_registration" do
          number_of_past_registrations = registration.past_registrations.count
          renewal_completion_service.complete_renewal
          expect(registration.reload.past_registrations.count).to eq(number_of_past_registrations + 1)
        end

        it "copies attributes from the transient_registration to the registration" do
          renewal_completion_service.complete_renewal
          expect(registration.reload.company_name).to eq(transient_registration.company_name)
        end

        it "does not update the renew_token" do
          old_token = registration.renew_token
          renewal_completion_service.complete_renewal

          registration.reload
          expect(registration.renew_token).to eq(old_token)
        end

        it "copies nested attributes from the transient_registration to the registration" do
          registration.registered_address.update_attributes(postcode: "FOO")
          renewal_completion_service.complete_renewal
          expect(registration.reload.registered_address.postcode).to eq(transient_registration.registered_address.postcode)
        end

        it "adds the order from the transient_registration" do
          new_order = transient_registration.finance_details.orders.first
          renewal_completion_service.complete_renewal
          expect(registration.reload.finance_details.orders).to include(new_order)
        end

        it "adds the payment from the transient_registration" do
          new_payment = transient_registration.finance_details.payments.first
          renewal_completion_service.complete_renewal
          expect(registration.reload.finance_details.payments).to include(new_payment)
        end

        it "copies the registration's route from the transient_registration to the registration" do
          transient_registration.metaData.route = "ASSISTED_DIGITAL_FROM_TRANSIENT_REGISTRATION"
          transient_registration.save

          renewal_completion_service.complete_renewal

          expect(registration.reload.metaData.route).to eq("ASSISTED_DIGITAL_FROM_TRANSIENT_REGISTRATION")
        end

        it "keeps existing orders" do
          old_order = registration.finance_details.orders.first
          renewal_completion_service.complete_renewal
          expect(registration.reload.finance_details.orders).to include(old_order)
        end

        it "keeps existing payments" do
          old_payment = registration.finance_details.payments.first
          renewal_completion_service.complete_renewal
          expect(registration.reload.finance_details.payments).to include(old_payment)
        end

        it "updates the balance" do
          old_reg_balance = registration.finance_details.balance
          transient_reg_balance = transient_registration.finance_details.balance

          renewal_completion_service.complete_renewal
          expect(registration.reload.finance_details.balance).to eq(
            old_reg_balance + transient_reg_balance
          )
        end

        it "extends expires_on by 3 years" do
          old_expiry_date = registration.expires_on
          renewal_completion_service.complete_renewal
          new_expiry_date = registration.reload.expires_on

          expect(new_expiry_date.to_date).to eq((old_expiry_date.to_date + 3.years))
        end

        it "updates the registration's date_registered" do
          Timecop.freeze do
            renewal_completion_service.complete_renewal

            date_registered = registration.reload.metaData.date_registered

            expect(date_registered.to_time.to_s).to eq(Time.now.to_s)
          end
        end

        it "updates the registration's date_activated" do
          Timecop.freeze do
            renewal_completion_service.complete_renewal

            date_activated = registration.reload.metaData.date_activated

            expect(date_activated.to_time.to_s).to eq(Time.now.to_s)
          end
        end

        it "updates the registration's last_modified" do
          Timecop.freeze do
            renewal_completion_service.complete_renewal

            last_modified = registration.reload.metaData.last_modified

            expect(last_modified.to_time.to_s).to eq(Time.now.to_s)
          end
        end

        it "creates the correct number of order item logs" do
          expect { renewal_completion_service.complete_renewal }.to change { OrderItemLog.count }
            .from(0)
            .to(transient_registration.finance_details.orders.sum { |o| o.order_items.length })
        end

        # This only applies to attributes where a value could be set, but not always - for example, smart answers
        context "if the registration has an attribute which is not in the transient_registration" do
          before do
            registration.update_attributes(construction_waste: true)
          end

          it "updates the attribute to be nil in the registration" do
            renewal_completion_service.complete_renewal
            expect(registration.reload.construction_waste).to eq(nil)
          end
        end

        it "copies the first_name to the contact address" do
          first_name = transient_registration.first_name
          renewal_completion_service.complete_renewal
          expect(registration.reload.contact_address.first_name).to eq(first_name)
        end

        it "copies the last_name to the contact address" do
          last_name = transient_registration.last_name
          renewal_completion_service.complete_renewal
          expect(registration.reload.contact_address.last_name).to eq(last_name)
        end

        it "deletes the transient registration" do
          renewal_completion_service.complete_renewal
          expect(RenewingRegistration.where(reg_identifier: transient_registration.reg_identifier).count).to eq(0)
        end

        it "sends a confirmation email" do
          expect(Notify::RenewalConfirmationEmailService)
            .to receive(:run)
            .with(registration: registration)
            .once

          renewal_completion_service.complete_renewal
        end
      end

      context "when the renewal cannot be completed" do
        context "when the renewal is in the wrong status" do
          before do
            registration.update_attributes!(metaData: build(:metaData, :has_required_data, status: "REVOKED"))
          end

          it "raises a WrongStatus error" do
            expect { renewal_completion_service.complete_renewal }.to raise_error(WasteCarriersEngine::RenewalCompletionService::WrongStatus)
          end
        end

        context "when the renewal balance is not 0" do
          before do
            transient_registration.finance_details.balance = 34
            transient_registration.save
          end

          it "raises a StillUnpaidBalance error" do
            expect { renewal_completion_service.complete_renewal }.to raise_error(WasteCarriersEngine::RenewalCompletionService::StillUnpaidBalance)
          end
        end

        context "when the workflow state is incorrect" do
          before do
            transient_registration.workflow_state = :worldpay_form
            transient_registration.save
          end

          it "raises a WrongWorkflowState error" do
            expect { renewal_completion_service.complete_renewal }.to raise_error(WasteCarriersEngine::RenewalCompletionService::WrongWorkflowState)
          end
        end

        context "when there are pending conviction checks" do
          let(:transient_registration) do
            create(
              :renewing_registration,
              :has_required_data,
              :has_addresses,
              :has_key_people,
              :has_paid_order,
              :requires_conviction_check,
              company_name: "FooBiz",
              workflow_state: "renewal_complete_form"
            )
          end

          it "raises a PendingConvictionCheck error" do
            expect { renewal_completion_service.complete_renewal }.to raise_error(WasteCarriersEngine::RenewalCompletionService::PendingConvictionCheck)
          end
        end
      end

      context "when the mailer fails" do
        before do
          the_error = StandardError.new("Oops!")

          allow(Notify::RenewalConfirmationEmailService)
            .to receive(:run)
            .and_raise(the_error)

          expect(Airbrake)
            .to receive(:notify)
            .with(the_error, { registration_no: transient_registration.reg_identifier })
        end

        it "notifies Airbrake" do
          renewal_completion_service.complete_renewal
        end
      end
    end
  end
end
