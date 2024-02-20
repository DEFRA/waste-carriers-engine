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
        :has_paid_order_with_two_orders,
        company_name: "FooBiz",
        workflow_state: "renewal_complete_form"
      )
    end
    let(:registration) { Registration.where(reg_identifier: transient_registration.reg_identifier).first }

    let(:renewal_completion_service) { described_class.new(transient_registration) }

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

      subject(:complete_renewal) { renewal_completion_service.complete_renewal }

      before do
        allow(Notify::RenewalConfirmationEmailService).to receive(:run)
        allow(Notify::RenewalConfirmationLetterService).to receive(:run)
      end

      context "when the renewal can be completed" do
        it "creates a new past_registration" do
          expect { complete_renewal }.to change { registration.reload.past_registrations.count }.by(1)
        end

        it "copies attributes from the transient_registration to the registration" do
          expect { complete_renewal }.to change { registration.reload.company_name }
                                     .to(transient_registration.company_name)
        end

        context "when all temporary attributes are populated" do
          before do
            TransientRegistration.fields.keys.select { |t| t.start_with?("temp_") }.each do |temp_field|
              unless transient_registration.send(temp_field).present?
                transient_registration.send("#{temp_field}=", "yes")
              end
            end
            transient_registration.save!
          end

          it "does not raise an exception" do
            expect { complete_renewal }.not_to raise_error
          end
        end

        it "does not update the renew_token" do
          expect { complete_renewal }.not_to change(registration, :renew_token)
        end

        it "copies nested attributes from the transient_registration to the registration" do
          registration.registered_address.update_attributes(postcode: "FOO")
          expect { complete_renewal }.to change { registration.reload.registered_address.postcode }
                                     .to(transient_registration.registered_address.postcode)
        end

        it "adds the order from the transient_registration" do
          expect { complete_renewal }.to change { registration.reload.finance_details.orders.length }.by(2)
        end

        it "adds the payment from the transient_registration" do
          expect { complete_renewal }.to change { registration.reload.finance_details.payments.length }.by(3)
        end

        it "copies the registration's route from the transient_registration to the registration" do
          transient_registration.metaData.update(route: "ASSISTED_DIGITAL")

          expect { complete_renewal }.to change { registration.reload.metaData.route }.to("ASSISTED_DIGITAL")
        end

        it "keeps existing orders" do
          old_order = registration.finance_details.orders.first
          complete_renewal
          expect(registration.reload.finance_details.orders).to include(old_order)
        end

        it "keeps existing payments" do
          old_payment = registration.finance_details.payments.first
          complete_renewal
          expect(registration.reload.finance_details.payments).to include(old_payment)
        end

        it "updates the balance" do
          old_reg_balance = registration.finance_details.balance
          # Ensure that transient_registration has a non-zero balance
          transient_registration.finance_details.payments << build(:payment, amount: 50)
          transient_registration.finance_details.update_balance
          transient_registration.save!
          transient_reg_balance = transient_registration.finance_details.balance

          expect { complete_renewal }.to change { registration.reload.finance_details.balance }
                                     .to(old_reg_balance + transient_reg_balance)
        end

        it "extends expires_on by 3 years" do
          old_expiry_date = registration.expires_on
          expect { complete_renewal }.to change { registration.reload.expires_on }
                                     .to(old_expiry_date.to_date + 3.years)
        end

        it "updates the registration's date_registered" do
          Timecop.freeze do
            complete_renewal

            expect(registration.reload.metaData.date_registered.to_time.to_s).to eq(Time.now.to_s)
          end
        end

        it "updates the registration's date_activated" do
          Timecop.freeze do
            complete_renewal

            expect(registration.reload.metaData.date_activated.to_time.to_s).to eq(Time.now.to_s)
          end
        end

        it "updates the registration's last_modified" do
          Timecop.freeze do
            complete_renewal

            expect(registration.reload.metaData.last_modified.to_time.to_s).to eq(Time.now.to_s)
          end
        end

        it "creates the correct number of order item logs" do
          expect { complete_renewal }.to change(OrderItemLog, :count)
            .from(0)
            .to(transient_registration.finance_details.orders.sum { |o| o.order_items.length })
        end

        it "creates the order item logs with the correct activated at" do
          activated_at = transient_registration.metaData.dateActivated
          complete_renewal
          order_item_logs_activated_ats = OrderItemLog.all.pluck(:activated_at)

          # The order item logs activated_at values are sometimes a second off the
          # source registration metadata value, despite being a direct copy
          expect(order_item_logs_activated_ats).to all(be_within(1.second).of(activated_at))
        end

        describe "creating a view certificate token" do
          context "when the registration has a view_certificate_token" do
            before { registration.update_attributes(view_certificate_token: "foo") }

            it "does not update the view_certificate_token" do
              expect { complete_renewal }.not_to change { registration.reload.view_certificate_token }.from("foo")
            end
          end

          context "when the registration does not have a view_certificate_token" do
            it "creates a view_certificate_token" do
              expect { complete_renewal }.to change { registration.reload.view_certificate_token }.from(nil)
            end
          end
        end

        # This only applies to attributes where a value could be set, but not always - for example, smart answers
        context "when the registration has an attribute which is not in the transient_registration" do
          before { registration.update_attributes(construction_waste: true) }

          it "updates the attribute to be nil in the registration" do
            expect { complete_renewal }.to change { registration.reload.construction_waste }.to(nil)
          end
        end

        it "copies key people" do
          transient_registration.key_people << build(:key_person, :has_required_data)
          expect { complete_renewal }.to change { registration.reload.key_people.count }.by(1)
        end

        it "copies location" do
          transient_registration.update(location: "scotland")
          expect { complete_renewal }.to change { registration.reload.location }.to("scotland")
        end

        it "copies the first_name to the contact address" do
          first_name = transient_registration.first_name
          expect { complete_renewal }.to change { registration.reload.contact_address.first_name }.to(first_name)
        end

        it "copies the last_name to the contact address" do
          last_name = transient_registration.last_name
          expect { complete_renewal }.to change { registration.reload.contact_address.last_name }.to(last_name)
        end

        it "deletes the transient registration" do
          complete_renewal
          expect(RenewingRegistration.where(reg_identifier: transient_registration.reg_identifier).count).to eq(0)
        end

        it "sends a confirmation email" do
          complete_renewal

          expect(Notify::RenewalConfirmationEmailService).to have_received(:run).with(registration: registration).once
        end

        context "when there is no contact email" do
          before { transient_registration.update_attributes(contact_email: nil) }

          it "sends a confirmation letter" do
            complete_renewal

            expect(Notify::RenewalConfirmationLetterService).to have_received(:run).with(registration: registration).once
          end
        end

        it "resets the certificate version" do
          registration.metaData.update_attributes(certificate_version: 3)

          expect { complete_renewal }.to change { registration.reload.metaData.certificate_version }.from(3).to(0)
        end

        it "updates certificate version history" do
          expect { complete_renewal }.to change { registration.reload.metaData.certificate_version_history.length }.by(1)
        end

        it "sets certificate version history timestamp" do
          complete_renewal

          expect(registration.reload.metaData.certificate_version_history.last[:generated_at]).to be_present
        end
      end

      context "when the renewal cannot be completed" do
        context "when the renewal is in the wrong status" do
          before { registration.update_attributes!(metaData: build(:metaData, :has_required_data, status: "REVOKED")) }

          it "raises a WrongStatus error" do
            expect { complete_renewal }.to raise_error(WasteCarriersEngine::RenewalCompletionService::WrongStatus)
          end
        end

        context "when the renewal balance is not 0" do
          before do
            transient_registration.finance_details.balance = 34
            transient_registration.save
          end

          it "raises a StillUnpaidBalance error" do
            expect { complete_renewal }.to raise_error(WasteCarriersEngine::RenewalCompletionService::StillUnpaidBalance)
          end
        end

        context "when the workflow state is incorrect" do
          before do
            transient_registration.workflow_state = :govpay_form
            transient_registration.save
          end

          it "raises a WrongWorkflowState error" do
            expect { complete_renewal }.to raise_error(WasteCarriersEngine::RenewalCompletionService::WrongWorkflowState)
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
            expect { complete_renewal }.to raise_error(WasteCarriersEngine::RenewalCompletionService::PendingConvictionCheck)
          end
        end
      end

      context "when the mailer fails" do
        before do
          the_error = StandardError.new("Oops!")

          allow(Notify::RenewalConfirmationEmailService)
            .to receive(:run)
            .and_raise(the_error)

          allow(Airbrake)
            .to receive(:notify)
            .with(the_error, { registration_no: transient_registration.reg_identifier })
        end

        it "notifies Airbrake" do
          complete_renewal

          expect(Airbrake).to have_received(:notify)
        end
      end
    end
  end
end
