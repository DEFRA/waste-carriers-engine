# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RegistrationCompletionService do
    describe ".run" do
      let(:transient_registration) do
        create(
          :new_registration,
          :has_required_data
        )
      end

      it "generates a new registration and copy data to it" do
        registration_scope = WasteCarriersEngine::Registration.where(reg_identifier: transient_registration.reg_identifier)

        expect(registration_scope.any?).to be_falsey

        registration = described_class.run(transient_registration)

        expect(registration.reg_identifier).to be_present
        expect(registration.contact_address).to be_present
        expect(registration.company_address).to be_present
        expect(registration.expires_on).to be_present
        expect(registration.metaData.route).to be_present
        expect(registration.metaData.date_registered).to be_present
        expect(registration).to be_pending
      end

      it "deletes the transient registration" do
        token = transient_registration.token

        described_class.run(transient_registration)

        new_registration_scope = WasteCarriersEngine::NewRegistration.where(token: token)

        expect(new_registration_scope.any?).to be_falsey
      end

      context "when the registration is a lower tier registration" do
        let(:transient_registration) do
          create(
            :new_registration,
            :has_required_lower_tier_data
          )
        end

        it "activates the registration, set up finance details and does not set an expire date" do
          registration = described_class.run(transient_registration)

          expect(registration.expires_on).to be_nil
          expect(registration).to be_active
          expect(registration.finance_details).to be_present
          expect(registration.finance_details.orders.count).to eq(1)
          expect(registration.finance_details.balance).to eq(0)
        end
      end

      context "when the balance have been cleared and there are no pending convictions checks" do
        let(:finance_details) { build(:finance_details, :has_paid_order_and_payment) }

        before do
          transient_registration.finance_details = finance_details
          transient_registration.save
        end

        it "activates the registration" do
          registration = described_class.run(transient_registration)

          expect(registration).to be_active
        end
      end

      context "when there is a pending balance" do
        let(:finance_details) { build(:finance_details, :has_required_data) }

        before do
          transient_registration.finance_details = finance_details
          transient_registration.save
        end

        it "sends a confirmation email" do
          expect(NewRegistrationMailer).to receive(:registration_pending_payment).and_call_original
          expect { described_class.run(transient_registration) }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end

        context "when the mailer fails" do
          before do
            allow(Rails.configuration.action_mailer).to receive(:raise_delivery_errors).and_return(true)
            allow_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now).and_raise(StandardError)
          end

          it "does not raise an error" do
            expect { described_class.run(transient_registration) }.to_not raise_error
          end
        end
      end
    end
  end
end
