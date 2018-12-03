# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    let(:transient_registration) { build(:transient_registration, :has_required_data) }

    describe "workflow_state" do
      context "when a TransientRegistration is created" do
        it "has the state :renewal_start_form" do
          expect(transient_registration).to have_state(:renewal_start_form)
        end
      end
    end

    describe "reg_identifier" do
      context "when a TransientRegistration is created" do
        it "is not valid if the reg_identifier is in the wrong format" do
          transient_registration.reg_identifier = "foo"
          expect(transient_registration).to_not be_valid
        end

        it "is not valid if no matching registration exists" do
          transient_registration.reg_identifier = "CBDU999999"
          expect(transient_registration).to_not be_valid
        end

        it "is not valid if the reg_identifier is already in use" do
          existing_transient_registration = create(:transient_registration, :has_required_data)
          transient_registration.reg_identifier = existing_transient_registration.reg_identifier
          expect(transient_registration).to_not be_valid
        end
      end
    end

    describe "scope" do
      it_should_behave_like "TransientRegistration named scopes"
    end

    describe "registration attributes" do
      it_should_behave_like "Can have registration attributes"
    end

    describe "#initialize" do
      context "when the source registration has whitespace in its attributes" do
        let(:registration) do
          create(:registration,
                 :has_required_data,
                 company_name: " test ")
        end

        it "strips the whitespace from the attributes" do
          transient_registration = TransientRegistration.new(reg_identifier: registration.reg_identifier)
          expect(transient_registration.company_name).to eq("test")
        end
      end

      context "when the source registration has a valid phone_number" do
        let(:registration) do
          create(:registration,
                 :has_required_data)
        end

        it "imports it" do
          transient_registration = TransientRegistration.new(reg_identifier: registration.reg_identifier)
          expect(transient_registration.phone_number).to eq(registration.phone_number)
        end
      end

      context "when the source registration has an invalid phone_number" do
        let(:registration) do
          create(:registration,
                 :has_required_data,
                 phone_number: "test")
        end

        it "does not import it" do
          transient_registration = TransientRegistration.new(reg_identifier: registration.reg_identifier)
          expect(transient_registration.phone_number).to eq(nil)
        end
      end

      context "when the source registration has a revoked_reason" do
        let(:revoked_transient_registration) { build(:transient_registration, :has_revoked_registration) }

        it "does not import it" do
          expect(revoked_transient_registration.metaData.revoked_reason).to eq(nil)
        end
      end
    end

    describe "#registration_type_changed?" do
      context "when a TransientRegistration is created" do
        it "should return false" do
          expect(transient_registration.registration_type_changed?).to eq(false)
        end

        context "when the registration_type is updated" do
          before(:each) do
            transient_registration.registration_type = "broker_dealer"
          end

          it "should return true" do
            expect(transient_registration.registration_type_changed?).to eq(true)
          end
        end
      end
    end

    describe "#renewal_application_submitted?" do
      context "when the workflow_state is not a completed one" do
        it "returns false" do
          expect(transient_registration.renewal_application_submitted?).to eq(false)
        end
      end

      context "when the workflow_state is renewal_received" do
        before do
          transient_registration.workflow_state = "renewal_received_form"
        end

        it "returns true" do
          expect(transient_registration.renewal_application_submitted?).to eq(true)
        end
      end

      context "when the workflow_state is renewal_complete" do
        before do
          transient_registration.workflow_state = "renewal_complete_form"
        end

        it "returns true" do
          expect(transient_registration.renewal_application_submitted?).to eq(true)
        end
      end
    end

    describe "#pending_payment?" do
      context "when the renewal is not in a completed workflow_state" do
        it "returns false" do
          expect(transient_registration.pending_payment?).to eq(false)
        end
      end

      context "when the renewal is in a completed workflow_state" do
        before do
          transient_registration.workflow_state = "renewal_received_form"
        end

        context "when the balance is 0" do
          before do
            transient_registration.finance_details = build(:finance_details, balance: 0)
          end

          it "returns false" do
            expect(transient_registration.pending_payment?).to eq(false)
          end
        end

        context "when the balance is negative" do
          before do
            transient_registration.finance_details = build(:finance_details, balance: -1)
          end

          it "returns false" do
            expect(transient_registration.pending_payment?).to eq(false)
          end
        end

        context "when the balance is positive" do
          before do
            transient_registration.finance_details = build(:finance_details, balance: 1)
          end

          it "returns true" do
            expect(transient_registration.pending_payment?).to eq(true)
          end
        end
      end
    end

    describe "#pending_worldpay_payment?" do
      context "when the renewal has an order" do
        before do
          transient_registration.finance_details = build(:finance_details, :has_order)
        end

        context "when the order's world_pay_status is pending" do
          before do
            allow(Order).to receive(:valid_world_pay_status?).and_return(true)
          end

          it "returns true" do
            expect(transient_registration.pending_worldpay_payment?).to eq(true)
          end
        end

        context "when the order's world_pay_status is not pending" do
          before do
            allow(Order).to receive(:valid_world_pay_status?).and_return(false)
          end

          it "returns false" do
            expect(transient_registration.pending_worldpay_payment?).to eq(false)
          end
        end
      end

      context "when the renewal has no order" do
        before do
          transient_registration.finance_details = build(:finance_details)
        end

        it "returns false" do
          expect(transient_registration.pending_worldpay_payment?).to eq(false)
        end
      end
    end

    describe "#pending_manual_conviction_check?" do
      context "when the renewal is not in a completed workflow_state" do
        it "returns false" do
          expect(transient_registration.pending_manual_conviction_check?).to eq(false)
        end
      end

      context "when the renewal is in a completed workflow_state" do
        before do
          transient_registration.workflow_state = "renewal_received_form"
        end

        context "when conviction_check_required? is false" do
          before do
            allow(transient_registration).to receive(:conviction_check_required?).and_return(false)
          end

          it "returns false" do
            expect(transient_registration.pending_manual_conviction_check?).to eq(false)
          end
        end

        context "when conviction_check_required? is true" do
          before do
            allow(transient_registration).to receive(:conviction_check_required?).and_return(true)
          end

          context "when the registration is not active" do
            let(:revoked_transient_registration) { build(:transient_registration, :has_revoked_registration) }

            it "returns false" do
              expect(revoked_transient_registration.pending_manual_conviction_check?).to eq(false)
            end
          end

          context "when the registration is active" do
            it "returns true" do
              expect(transient_registration.pending_manual_conviction_check?).to eq(true)
            end
          end
        end
      end
    end

    describe "#can_be_renewed?" do
      context "when the declaration is confirmed" do
        it "returns true" do
          transient_registration.declaration = 1
          expect(transient_registration.can_be_renewed?).to eq(true)
        end
      end

      context "when a registration is neither active or expired" do
        let(:revoked_transient_registration) { build(:transient_registration, :has_revoked_registration) }

        it "returns false" do
          expect(revoked_transient_registration.can_be_renewed?).to eq(false)
        end
      end

      context "when a registration is active" do
        it "returns true" do
          expect(transient_registration.can_be_renewed?).to eq(true)
        end

        context "and when dealing with the 'renewal window'" do
          before { allow(Rails.configuration).to receive(:renewal_window).and_return(3) }

          context "when it expires in the 'renewal window'" do
            it "returns true" do
              freeze_date = transient_registration.expires_on - 1.month
              Timecop.freeze(freeze_date) do
                expect(transient_registration.can_be_renewed?).to eq(true)
              end
            end
          end

          context "when it expires outside the 'renewal window'" do
            it "returns false" do
              freeze_date = transient_registration.expires_on - 4.month
              Timecop.freeze(freeze_date) do
                expect(transient_registration.can_be_renewed?).to eq(false)
              end
            end
          end

          context "when there is no 'renewal window'" do
            before { allow(Rails.configuration).to receive(:renewal_window).and_return(0) }

            it "returns true" do
              freeze_date = transient_registration.expires_on
              Timecop.freeze(freeze_date) do
                expect(transient_registration.can_be_renewed?).to eq(true)
              end
            end
          end
        end
      end

      context "when a registration is expired" do
        let(:expired_transient_registration) { build(:transient_registration, :has_expired) }

        it "returns false" do
          expect(expired_transient_registration.can_be_renewed?).to eq(false)
        end

        context "and when dealing with the 'grace window'" do
          before { allow(Rails.configuration).to receive(:grace_window).and_return(3) }

          let(:expired_today_transient_registration) { build(:transient_registration, :has_expired_today) }

          context "when outside it" do
            it "returns false" do
              freeze_date = expired_today_transient_registration.expires_on + Rails.configuration.grace_window
              Timecop.freeze(freeze_date) do
                expect(expired_today_transient_registration.can_be_renewed?).to eq(false)
              end
            end
          end

          context "when inside it" do
            it "returns true" do
              freeze_date = (expired_today_transient_registration.expires_on + Rails.configuration.grace_window) - 1.day
              Timecop.freeze(freeze_date) do
                expect(expired_today_transient_registration.can_be_renewed?).to eq(true)
              end
            end
          end

          context "when there is no 'grace window'" do
            before { allow(Rails.configuration).to receive(:grace_window).and_return(0) }

            it "returns false" do
              freeze_date = expired_today_transient_registration.expires_on + Rails.configuration.grace_window
              Timecop.freeze(freeze_date) do
                expect(expired_today_transient_registration.can_be_renewed?).to eq(false)
              end
            end
          end
        end
      end

      context "when the registration was created in BST and expires in GMT" do
        before { allow(Rails.configuration).to receive(:grace_window).and_return(3) }

        # Registration is made during British Summer Time (BST)
        # UK local time is 00:30 on 28 March 2017
        # UTC time is 23:30 on 27 March 2017
        # Registration should expire on 28 March 2020
        let!(:bst_transient_registration) do
          registration = create(:registration, :has_required_data)
          registration.metaData.status = "EXPIRED"
          registration.metaData.date_registered = Time.find_zone("London").local(2017, 3, 28, 0, 30)
          registration.expires_on = registration.metaData.date_registered + 3.years
          registration.save!
          TransientRegistration.new(reg_identifier: registration.reg_identifier)
        end

        it "does not expire a day early due to the time difference" do
          # Skip ahead to the end of the last day the reg should be active
          Timecop.freeze(Time.find_zone("London").local(2020, 3, 27, 23, 59)) do
            # GMT is now in effect (not BST)
            # UK local time & UTC are both 23:59 on 27 March 2020
            expect(bst_transient_registration.can_be_renewed?).to eq(true)
          end
        end

        it "cannot be renewed when it reaches the expiry date plus 'grace window' in the UK" do
          # Skip ahead to the start of the day a reg should expire, plus the
          # grace window
          Timecop.freeze(Time.find_zone("London").local(2020, 3, 31, 0, 1)) do
            # GMT is now in effect (not BST)
            # UK local time & UTC are both 00:01 on 28 March 2020
            expect(bst_transient_registration.can_be_renewed?).to eq(false)
          end
        end
      end
    end

    context "when the registration was created in GMT and expires in BST" do
      before { allow(Rails.configuration).to receive(:grace_window).and_return(3) }

      # Registration is made in during Greenwich Mean Time (GMT)
      # UK local time & UTC are both 23:30 on 27 October 2015
      # Registration should expire on 27 October 2018
      let!(:gmt_registration) do
        registration = build(:registration, :has_required_data)
        registration.metaData.status = "EXPIRED"
        registration.metaData.date_registered = Time.find_zone("London").local(2015, 10, 27, 23, 30)
        registration.expires_on = registration.metaData.date_registered + 3.years
        registration.save!
        TransientRegistration.new(reg_identifier: registration.reg_identifier)
      end

      it "does not expire a day early due to the time difference" do
        # Skip ahead to the end of the last day the reg should be active
        Timecop.freeze(Time.find_zone("London").local(2018, 10, 26, 23, 59)) do
          # BST is now in effect (not GMT)
          # UK local time is 23:59 on 26 October 2018
          # UTC time is 22:59 on 26 October 2018
          expect(gmt_registration.can_be_renewed?).to eq(true)
        end
      end

      it "cannot be renewed when it reaches the expiry date plus 'grace window' in the UK" do
        # Skip ahead to the start of the day a reg should expire, plus the
        # grace window
        Timecop.freeze(Time.find_zone("London").local(2018, 10, 30, 0, 1)) do
          # BST is now in effect (not GMT)
          # UK local time is 00:01 on 27 October 2018
          # UTC time is 23:01 on 26 October 2018
          expect(gmt_registration.can_be_renewed?).to eq(false)
        end
      end
    end

    describe "#ready_to_complete?" do
      context "when the transient registration is ready to complete" do
        let(:transient_registration) { build(:transient_registration, :is_ready_to_complete) }
        it "returns true" do
          expect(transient_registration.ready_to_complete?).to eq(true)
        end
      end
      context "when the transient registration is not ready to complete" do
        context "because it is not submitted" do
          let(:transient_registration) { build(:transient_registration, workflow_state: "bank_transfer_form") }
          it "returns false" do
            expect(transient_registration.ready_to_complete?).to eq(false)
          end
        end
        context "because it has outstanding payments" do
          it "returns false" do
            expect(transient_registration.ready_to_complete?).to eq(false)
          end
        end
        context "because it has outstanding conviction checks" do
          it "returns false" do
            expect(transient_registration.ready_to_complete?).to eq(false)
          end
        end
      end
    end
  end
end
