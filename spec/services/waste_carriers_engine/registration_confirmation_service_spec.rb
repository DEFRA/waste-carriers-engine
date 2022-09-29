# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RegistrationConfirmationService do
    describe ".run" do
      let(:registration) { create(:registration, :has_required_data) }

      subject(:run_service) { described_class.run(registration: registration) }

      before do
        allow(Airbrake).to receive(:notify)
        allow(Notify::RegistrationConfirmationEmailService).to receive(:run)
        allow(Notify::RegistrationConfirmationLetterService).to receive(:run)
      end

      context "with a valid contact email" do
        it "sends a confirmation email" do
          run_service

          expect(Notify::RegistrationConfirmationEmailService)
            .to have_received(:run)
            .with(registration: registration)
            .once
        end

        context "when an error occurs" do
          it "notifies Airbrake" do
            the_error = StandardError.new("Oops!")

            allow(Notify::RegistrationConfirmationEmailService)
              .to receive(:run)
              .with(registration: registration)
              .and_raise(the_error)

            run_service

            expect(Airbrake)
              .to have_received(:notify)
              .with(the_error, { registration_no: registration.reg_identifier })
          end
        end
      end

      context "with a nil contact email" do
        before do
          registration.contact_email = nil
        end

        it "sends a confirmation letter" do
          run_service

          expect(Notify::RegistrationConfirmationLetterService)
            .to have_received(:run)
            .with(registration: registration)
            .once
        end
      end

      context "with a blank email address" do
        before { registration.contact_email = nil }

        it "sends a confirmation letter" do
          run_service

          expect(Notify::RegistrationConfirmationLetterService)
            .to have_received(:run)
            .with(registration: registration)
            .once
        end
      end
    end
  end
end
