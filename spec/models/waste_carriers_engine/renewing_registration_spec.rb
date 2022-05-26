# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject(:renewing_registration) { build(:renewing_registration, :has_required_data) }

    it_should_behave_like "Can check if registration type changed"

    describe "scopes" do
      it_should_behave_like "TransientRegistration named scopes"
    end

    describe "workflow_state" do
      context "when a RenewingRegistration is created" do
        it "has the state :renewal_start_form" do
          expect(renewing_registration).to have_state(:renewal_start_form)
        end
      end

      context "when transitioning from confirm_bank_transfer_form to renewal_received_pending_payment_form successfully" do
        it "set the transient registration metadata route" do
          expect(renewing_registration).to receive(:set_metadata_route).once

          renewing_registration.update_attributes(workflow_state: :confirm_bank_transfer_form)
          renewing_registration.next
        end
      end

      context "when transitioning from worldpay_form to renewal_complete_form successfully" do
        it "set the transient registration metadata route" do
          expect(renewing_registration).to receive(:set_metadata_route).once
          expect(renewing_registration).to receive(:pending_worldpay_payment?).and_return(false)
          expect(renewing_registration).to receive(:conviction_check_required?).and_return(false)

          renewing_registration.update_attributes(workflow_state: :worldpay_form)
          renewing_registration.next
        end
      end

      context "when transitioning from worldpay_form to renewal_received_pending_conviction_form succesfully" do
        it "set the transient registration metadata route" do
          expect(renewing_registration).to receive(:set_metadata_route).once
          expect(renewing_registration).to receive(:pending_worldpay_payment?).and_return(false)
          expect(renewing_registration).to receive(:conviction_check_required?).and_return(true)

          renewing_registration.update_attributes(workflow_state: :worldpay_form)
          renewing_registration.next
        end
      end
    end

    context "Validations" do
      describe "reg_identifier" do
        context "when a RenewingRegistration is created" do
          it "is not valid if the reg_identifier is in the wrong format" do
            renewing_registration.reg_identifier = "foo"
            expect(renewing_registration).to_not be_valid
          end

          it "is not valid if no matching registration exists" do
            renewing_registration.reg_identifier = "CBDU999999"
            expect(renewing_registration).to_not be_valid
          end

          it "is not valid if the reg_identifier is already in use" do
            existing_renewing_registration = create(:renewing_registration, :has_required_data)
            renewing_registration.reg_identifier = existing_renewing_registration.reg_identifier
            expect(renewing_registration).to_not be_valid
          end
        end
      end
    end

    describe "#initialize" do
      context "when the source registration has whitespace in its attributes" do
        let(:registration) do
          create(:registration,
                 :has_required_data,
                 company_name: " test ")
        end

        it "strips the whitespace from the attributes" do
          renewing_registration = RenewingRegistration.new(reg_identifier: registration.reg_identifier)
          expect(renewing_registration.company_name).to eq("test")
        end
      end

      context "when the source registration has a revoked_reason" do
        let(:revoked_renewing_registration) { build(:renewing_registration, :has_revoked_registration) }

        it "does not import it" do
          expect(revoked_renewing_registration.metaData.revoked_reason).to eq(nil)
        end
      end

      context "when copying data from the source registration" do
        let(:registration) do
          create(:registration,
                 :has_required_data,
                 first_name: "Mary",
                 last_name: "Wollstonecraft",
                 phone_number: "01234 567890",
                 contact_email: "mary@example.com")
        end

        it "does not copy over private contact information" do
          renewing_registration = RenewingRegistration.new(reg_identifier: registration.reg_identifier)
          expect(renewing_registration.first_name).to eq(nil)
          expect(renewing_registration.last_name).to eq(nil)
          expect(renewing_registration.phone_number).to eq(nil)
          expect(renewing_registration.contact_email).to eq(nil)
        end
      end
    end

    describe "status" do
      it_should_behave_like "Can check registration status",
                            factory: :renewing_registration
    end

    describe "#renewal_application_submitted?" do
      context "when the workflow_state is not a completed one" do
        it "returns false" do
          expect(renewing_registration.renewal_application_submitted?).to eq(false)
        end
      end

      %w[renewal_received_pending_payment_form
         renewal_received_pending_conviction_form
         renewal_complete_form].each do |valid_state|
        context "when the workflow_state is #{valid_state}" do
          before do
            renewing_registration.workflow_state = valid_state
          end

          it "returns true" do
            expect(renewing_registration.renewal_application_submitted?).to eq(true)
          end
        end
      end
    end

    describe "#can_be_renewed?" do
      context "when a registration is neither active or expired" do
        let(:revoked_renewing_registration) { build(:renewing_registration, :has_revoked_registration) }

        it "returns false" do
          expect(revoked_renewing_registration.can_be_renewed?).to eq(false)
        end
      end

      context "when the declaration is confirmed" do
        it "returns true" do
          renewing_registration.declaration = 1
          expect(renewing_registration.can_be_renewed?).to eq(true)
        end
      end

      context "when a registration is active" do
        context "when it is within the grace window" do
          before { allow_any_instance_of(ExpiryCheckService).to receive(:in_expiry_grace_window?).and_return(true) }

          it "returns true" do
            expect(renewing_registration.can_be_renewed?).to eq(true)
          end
        end

        context "when it is not within the grace window" do
          before { allow_any_instance_of(ExpiryCheckService).to receive(:in_expiry_grace_window?).and_return(false) }

          context "and when it is within the renewal window" do
            before { allow_any_instance_of(ExpiryCheckService).to receive(:in_renewal_window?).and_return(true) }

            it "returns true" do
              expect(renewing_registration.can_be_renewed?).to eq(true)
            end
          end

          context "and when it is not within the renewal window" do
            before { allow_any_instance_of(ExpiryCheckService).to receive(:in_renewal_window?).and_return(false) }

            it "returns false" do
              expect(renewing_registration.can_be_renewed?).to eq(false)
            end
          end
        end
      end

      context "when a registration is expired" do
        let(:expired_renewing_registration) { build(:renewing_registration, :has_expired) }

        context "when a registration is active" do
          context "when it is within the grace window" do
            before { allow_any_instance_of(ExpiryCheckService).to receive(:in_expiry_grace_window?).and_return(true) }

            it "returns true" do
              expect(renewing_registration.can_be_renewed?).to eq(true)
            end
          end

          context "when it is not within the grace window" do
            before { allow_any_instance_of(ExpiryCheckService).to receive(:in_expiry_grace_window?).and_return(false) }

            context "and when it is within the renewal window" do
              before { allow_any_instance_of(ExpiryCheckService).to receive(:in_renewal_window?).and_return(true) }

              it "returns true" do
                expect(renewing_registration.can_be_renewed?).to eq(true)
              end
            end

            context "and when it is not within the renewal window" do
              before { allow_any_instance_of(ExpiryCheckService).to receive(:in_renewal_window?).and_return(false) }

              it "returns false" do
                expect(renewing_registration.can_be_renewed?).to eq(false)
              end
            end
          end
        end
      end
    end

    describe "#ready_to_complete?" do
      context "when the transient registration is ready to complete" do
        let(:renewing_registration) { build(:renewing_registration, :is_ready_to_complete) }
        it "returns true" do
          expect(renewing_registration.ready_to_complete?).to eq(true)
        end
      end

      context "when the transient registration is not ready to complete" do
        context "because it is not submitted" do
          let(:renewing_registration) { build(:renewing_registration, workflow_state: "bank_transfer_form") }
          it "returns false" do
            expect(renewing_registration.ready_to_complete?).to eq(false)
          end
        end

        context "because it has outstanding payments" do
          it "returns false" do
            expect(renewing_registration.ready_to_complete?).to eq(false)
          end
        end

        context "because it has outstanding conviction checks" do
          it "returns false" do
            expect(renewing_registration.ready_to_complete?).to eq(false)
          end
        end
      end
    end

    describe "#stuck?" do
      context "when the registration is not submitted" do
        let(:renewing_registration) { build(:renewing_registration, :has_required_data) }

        it "returns false" do
          expect(renewing_registration.stuck?).to eq(false)
        end
      end

      context "when the registration is submitted" do
        context "and has been revoked" do
          let(:renewing_registration) { build(:renewing_registration, :has_required_data, :is_submitted, :revoked) }

          it "returns false" do
            expect(renewing_registration.stuck?).to eq(false)
          end
        end

        context "and has an outstanding payment" do
          let(:renewing_registration) { build(:renewing_registration, :has_required_data, :has_unpaid_balance) }

          it "returns false" do
            expect(renewing_registration.stuck?).to eq(false)
          end
        end

        context "and has an outstanding conviction check" do
          let(:renewing_registration) { build(:renewing_registration, :has_required_data, :is_submitted, :requires_conviction_check) }

          it "returns false" do
            expect(renewing_registration.stuck?).to eq(false)
          end
        end

        context "and has no outstanding checks" do
          let(:renewing_registration) { build(:renewing_registration, :has_required_data, :is_submitted, :has_paid_balance) }

          it "returns true" do
            expect(renewing_registration.stuck?).to eq(true)
          end
        end
      end
    end

    describe "#pending_payment?" do
      context "when the renewal is not in a completed workflow_state" do
        it "returns false" do
          expect(renewing_registration.pending_payment?).to eq(false)
        end
      end

      context "when the renewal is in a completed workflow_state" do
        before do
          renewing_registration.workflow_state = "renewal_received_pending_payment_form"
        end

        context "when there is no unpaid balance" do
          before do
            allow(renewing_registration).to receive(:unpaid_balance?).and_return(false)
          end

          it "returns false" do
            expect(renewing_registration.pending_payment?).to eq(false)
          end
        end

        context "when there is an unpaid balance" do
          before do
            allow(renewing_registration).to receive(:unpaid_balance?).and_return(true)
          end

          it "returns true" do
            expect(renewing_registration.pending_payment?).to eq(true)
          end
        end
      end
    end

    describe "#pending_manual_conviction_check?" do
      context "when the renewal is not in a completed workflow_state" do
        it "returns false" do
          expect(renewing_registration.pending_manual_conviction_check?).to eq(false)
        end
      end

      context "when the renewal is in a completed workflow_state" do
        before do
          renewing_registration.workflow_state = "renewal_received_pending_payment_form"
        end

        context "when conviction_check_required? is false" do
          before do
            allow(renewing_registration).to receive(:conviction_check_required?).and_return(false)
          end

          it "returns false" do
            expect(renewing_registration.pending_manual_conviction_check?).to eq(false)
          end
        end

        context "when conviction_check_required? is true" do
          before do
            allow(renewing_registration).to receive(:conviction_check_required?).and_return(true)
          end

          context "when the registration is not active" do
            let(:revoked_renewing_registration) { build(:renewing_registration, :has_revoked_registration) }

            it "returns false" do
              expect(revoked_renewing_registration.pending_manual_conviction_check?).to eq(false)
            end
          end

          context "when the registration is active" do
            it "returns true" do
              expect(renewing_registration.pending_manual_conviction_check?).to eq(true)
            end
          end
        end
      end
    end
  end
end
