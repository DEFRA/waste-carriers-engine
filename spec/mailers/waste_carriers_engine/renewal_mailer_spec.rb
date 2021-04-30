# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewalMailer, type: :mailer do
    before do
      allow(Rails.configuration).to receive(:email_service_email).and_return("test@example.com")
    end

    describe "send_renewal_received_email" do
      let(:transient_registration) do
        create(:renewing_registration,
               :has_required_data,
               :has_addresses,
               :has_paid_balance,
               workflow_state: "renewal_received_pending_payment_form")
      end
      let(:mail) { RenewalMailer.send_renewal_received_email(transient_registration) }

      it "uses the correct 'to' address" do
        expect(mail.to).to eq([transient_registration.contact_email])
      end

      it "uses the correct 'from' address" do
        expect(mail.from).to eq(["test@example.com"])
      end

      it "includes the correct reg_identifier in the body" do
        expect(mail.body.encoded).to include(transient_registration.reg_identifier)
      end

      # this can be removed when the other renewal emails have migrated
      xcontext "when there is a pending worldpay payment" do
        before do
          allow(transient_registration).to receive(:pending_worldpay_payment?).and_return(true)
        end

        it "uses the correct subject" do
          subject = "Your application to renew waste carriers registration #{transient_registration.reg_identifier} has been received"
          expect(mail.subject).to eq(subject)
        end

        it "includes the correct template in the body" do
          expect(mail.body.encoded).to include("processing your payment")
        end
      end

      context "when there is an unpaid balance" do
        before do
          transient_registration.finance_details.balance = 550
        end

        it "uses the correct subject" do
          subject = "Payment needed for waste carrier registration #{transient_registration.reg_identifier}"
          expect(mail.subject).to eq(subject)
        end

        it "includes the correct template in the body" do
          expect(mail.body.encoded).to include("You need to pay for your waste carriers registration")
        end

        it "includes the correct balance in the body" do
          expect(mail.body.encoded).to include("5.50")
        end
      end

      context "when the balance is paid" do
        it "uses the correct subject" do
          subject = "Your application to renew waste carriers registration #{transient_registration.reg_identifier} has been received"
          expect(mail.subject).to eq(subject)
        end

        it "includes the correct template in the body" do
          expect(mail.body.encoded).to include("What happens next")
        end
      end
    end
  end
end
