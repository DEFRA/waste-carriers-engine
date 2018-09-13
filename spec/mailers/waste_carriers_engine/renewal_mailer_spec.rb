require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewalMailer, type: :mailer do
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
        expect(mail.subject).to eq("Renewal completed")
      end

      it "includes the correct text in the body" do
        expect(mail.body.encoded).to include("#{registration.reg_identifier} has been renewed")
      end
    end
  end
end
