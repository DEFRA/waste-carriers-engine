require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewalMailer, type: :mailer do
    before do
      allow(Rails.configuration).to receive(:email_service_email).and_return("test@example.com")
    end

    describe "send_renewal_complete_email" do
      let(:registration) { create(:registration, :has_required_data) }
      let(:mail) { RenewalMailer.send_renewal_complete_email(registration) }

      it "uses the correct 'to' address" do
        expect(mail.to).to eq([registration.contact_email])
      end

      it "uses the correct 'from' address" do
        expect(mail.from).to eq(["test@example.com"])
      end

      it "uses the correct subject" do
        subject = "Your waste carriers registration #{registration.reg_identifier} has been renewed"
        expect(mail.subject).to eq(subject)
      end

      it "includes the correct template in the body" do
        expect(mail.body.encoded).to include("Your registration number is still")
      end

      it "includes the correct reg_identifier in the body" do
        expect(mail.body.encoded).to include(registration.reg_identifier)
      end

      it "includes the correct address in the body" do
        expect(mail.body.encoded).to include(registration.registered_address.town_city)
      end
    end

    describe "send_renewal_received_email" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               :has_addresses,
               workflow_state: "renewal_received_form")
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

      it "includes the correct address in the body" do
        expect(mail.body.encoded).to include(transient_registration.registered_address.town_city)
      end

      context "when there is an unpaid balance" do
        before do
          transient_registration.finance_details = build(:finance_details, balance: 100)
        end

        it "uses the correct subject" do
          subject = "Your application to renew waste carriers registration #{transient_registration.reg_identifier} is awaiting payment"
          expect(mail.subject).to eq(subject)
        end

        it "includes the correct template in the body" do
          expect(mail.body.encoded).to include("Your registration number is still")
        end
      end

      context "when the balance is paid" do
        before do
          transient_registration.finance_details = build(:finance_details, balance: 0)
        end

        it "uses the correct subject" do
          subject = "Your application to renew waste carriers registration #{transient_registration.reg_identifier} has been received"
          expect(mail.subject).to eq(subject)
        end

        it "includes the correct template in the body" do
          expect(mail.body.encoded).to include("Your registration number is still")
        end
      end
    end
  end
end
