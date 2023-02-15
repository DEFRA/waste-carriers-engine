# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RegistrationDeactivationService do
    describe ".run" do

      let(:registration_status) { "ACTIVE" }
      let(:registration) do
        create(:registration, :has_required_data, (registration_status == "ACTIVE" ? :is_active : :is_inactive))
      end
      let(:metadata) { registration.metaData }
      let(:email_service) { instance_double(Notify::DeregistrationConfirmationEmailService) }

      before do
        allow(Notify::DeregistrationConfirmationEmailService).to receive(:new).and_return(email_service)
        allow(email_service).to receive(:run)
      end

      context "when run in the front office" do

        subject(:run_service) { described_class.run(registration: registration) }

        before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(false) }

        it "saves the contact_email" do
          expect { run_service }.to change(metadata, :deactivated_by).to(registration.contact_email)
        end

        it "saves the front-office revoked_reason" do
          expect { run_service }.to change(metadata, :revoked_reason)
                                .to(I18n.t(".front_office_deactivation_reason", email: registration.contact_email))
        end

        it "set status to inactive" do
          expect { run_service }.to change(metadata, :status).to("INACTIVE")
        end

        it "sets deactivation_route to DIGITAL" do
          expect { run_service }.to change(metadata, :deactivation_route).to("DIGITAL")
        end

        it "stores the deactivation time" do
          run_service

          expect(metadata.dateDeactivated.to_time).to be_within(2.seconds).of(Time.zone.now)
        end

        it "sends a confirmation email" do
          run_service

          expect(email_service).to have_received(:run).with(registration: registration)
        end

        context "when the registration is already inactive" do
          let(:registration_status) { "INACTIVE" }

          it "does not update the registration metadata" do
            expect { run_service }.not_to change(metadata, :status)
            expect { run_service }.not_to change(metadata, :dateDeactivated)
            expect { run_service }.not_to change(metadata, :revoked_reason)
            expect { run_service }.not_to change(metadata, :deactivated_by)
          end
        end
      end

      context "when run in the back office" do
        subject(:run_service) do
          described_class.run(registration: registration, email: user_email, reason: reason, status: status)
        end

        let(:user_email) { Faker::Internet.email }
        let(:reason) { Faker::Lorem.sentence }
        let(:status) { "REVOKED" }

        before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(true) }

        it "sets deactivation_route to BACK OFFICE" do
          expect { run_service }.to change(metadata, :deactivation_route).to("BACK OFFICE")
        end

        it "does not send an email" do
          run_service

          expect(email_service).not_to have_received(:run)
        end
      end
    end
  end
end
