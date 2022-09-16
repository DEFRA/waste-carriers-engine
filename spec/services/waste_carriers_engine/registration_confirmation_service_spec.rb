# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RegistrationConfirmationService do
    describe ".run" do
      let(:registration) { create(:registration, :has_required_data) }

      subject { described_class.run(registration: registration) }

      context "with a valid contact email" do
        it "sends a confirmation email" do
          expect(Notify::RegistrationConfirmationEmailService)
            .to receive(:run)
            .with(registration: registration)
            .once

          subject
        end

        context "when an error occurs" do
          it "notifies Airbrake" do
            the_error = StandardError.new("Oops!")

            allow(Notify::RegistrationConfirmationEmailService)
              .to receive(:run)
              .with(registration: registration)
              .and_raise(the_error)

            expect(Airbrake)
              .to receive(:notify)
              .with(the_error, { registration_no: registration.reg_identifier })

            subject
          end
        end
      end

      context "with a nil contact email" do
        before do
          registration.contact_email = nil
        end

        it "sends a confirmation letter" do
          expect(Notify::RegistrationConfirmationLetterService)
            .to receive(:run)
            .with(registration: registration)
            .once

          subject
        end
      end

      context "with a blank email address" do
        before { registration.contact_email = nil }

        it "sends a confirmation letter" do
          expect(Notify::RegistrationConfirmationLetterService)
            .to receive(:run)
            .with(registration: registration)
            .once

          subject
        end
      end
    end
  end
end
