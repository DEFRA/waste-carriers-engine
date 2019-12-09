# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistrationMailer, type: :mailer do
    before do
      allow(Rails.configuration).to receive(:email_service_email).and_return("test@example.com")
    end

    describe "registration_activated" do
      let(:registration) { create(:registration, :has_required_data, :expires_later) }
      let(:mail) { NewRegistrationMailer.registration_activated(registration) }

      it "uses the correct 'to' address" do
        expect(mail.to).to eq([registration.contact_email])
      end

      it "uses the correct 'from' address" do
        expect(mail.from).to eq(["test@example.com"])
      end

      it "uses the correct subject" do
        subject = "Waste Carrier Registration Complete"
        expect(mail.subject).to eq(subject)
      end

      it "includes the correct template in the body" do
        expect(mail.body.encoded).to include("You are now registered")
      end

      it "includes the correct reg_identifier in the body" do
        expect(mail.body.encoded).to include(registration.reg_identifier)
      end

      it "includes the correct address in the body" do
        expect(mail.body.encoded).to include(registration.registered_address.town_city)
      end

      context "attachments" do
        before(:all) do
          @registration = create(:registration, :has_required_data, :expires_later)
          @mail = NewRegistrationMailer.registration_activated(@registration)
          @pdf_attachment = @mail.attachments[0]
          @png_attachment = @mail.attachments[1]
        end

        it "has 2 attachments (pdf and logo)" do
          expect(@mail.attachments.length).to eq(2)
        end

        it "has an attachment of type pdf" do
          expect(@pdf_attachment.content_type).to start_with("application/pdf;")
        end

        it "has a pdf attachment with the right identifier in the filename" do
          expect(@pdf_attachment.filename).to eq("WasteCarrierRegistrationCertificate-#{@registration.reg_identifier}.pdf")
        end

        it "has an attachment of type png" do
          expect(@png_attachment.content_type).to start_with("image/png;")
        end

        it "has a png attachment with the right filename" do
          expect(@png_attachment.filename).to eq("govuk_logotype_email.png")
        end
      end

      context "error generating pdf attachment" do
        before do
          allow(GeneratePdfService).to receive(:new).and_raise(StandardError)
        end
        let(:registration) { create(:registration, :has_required_data, :expires_later) }
        let(:mail) { NewRegistrationMailer.registration_activated(registration) }

        it "does not block the email from completing" do
          expect(mail.to).to eq([registration.contact_email])
          expect(mail.from).to eq(["test@example.com"])
          expect(mail.attachments.length).to eq(1)
          expect(mail.attachments[0].filename).to eq("govuk_logotype_email.png")
        end
      end
    end
  end
end
