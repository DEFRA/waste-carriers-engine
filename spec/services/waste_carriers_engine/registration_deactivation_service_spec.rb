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

      subject(:run_service) { described_class.run(registration: registration) }

      context "when run in the front office" do
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
        before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(true) }

        it "saves the user's email address"
        it "saves the provided revoked_reason"
        it "set status to the provided status"
        it "sets deactivation_route to BACK OFFICE"
        it "stores the deactivation time"
      end

      # before do
      #   allow(transient_registration).to receive(:registration).and_return(registration)
      #   allow(transient_registration).to receive(:metaData).and_return(transient_registration_metadata)
      #   allow(transient_registration_metadata).to receive(:status).and_return(status)
      #   allow(transient_registration_metadata).to receive(:revoked_reason).and_return(revoked_reason)
      #   allow(transient_registration).to receive(:destroy)

      #   allow(registration_metadata).to receive(:status=)
      #   allow(registration_metadata).to receive(:revoked_reason=)

      #   allow(registration).to receive(:metaData).and_return(registration_metadata)
      #   allow(registration).to receive(:save!)
      # end

      # it "copies metadata from transient object to registration" do

      #   described_class.run(transient_registration)

      #   expect(registration_metadata).to have_received(:status=).with(status)
      #   expect(registration_metadata).to have_received(:revoked_reason=).with(revoked_reason)

      #   expect(transient_registration).to have_received(:destroy)
      #   expect(registration).to have_received(:save!)

      # end
    end
  end
end
