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
      let(:user_email) { Faker::Internet.email }
      let(:reason) { Faker::Lorem.sentence }
      let(:status) { "REVOKED" }

      subject(:run_service) do
        described_class.run(registration: registration, email: user_email, reason: reason, status: status)
      end

      it "sets deactivation_route to BACK OFFICE" do
        expect { run_service }.to change(metadata, :deactivation_route).to("BACK OFFICE")
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
  end
end
