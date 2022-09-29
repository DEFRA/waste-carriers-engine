# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ExpiryCheckService do
    # Registration is made during British Summer Time (BST)
    # UK local time is 00:30 on 28 March 2017
    # UTC time is 23:30 on 27 March 2017
    # Registration should expire on 28 March 2020
    let!(:bst_registration) do
      registration = create(:registration, :has_required_data)
      registration.metaData.status = "EXPIRED"
      registration.metaData.date_registered = Time.find_zone("London").local(2017, 3, 28, 0, 30)
      registration.expires_on = registration.metaData.date_registered + 3.years
      registration.save!
      registration
    end

    # Registration is made in during Greenwich Mean Time (GMT)
    # UK local time & UTC are both 23:30 on 27 October 2015
    # Registration should expire on 27 October 2018
    let!(:gmt_registration) do
      registration = build(:registration, :has_required_data)
      registration.metaData.status = "EXPIRED"
      registration.metaData.date_registered = Time.find_zone("London").local(2015, 10, 27, 23, 30)
      registration.expires_on = registration.metaData.date_registered + 3.years
      registration.save!
      registration
    end

    describe "#attributes" do
      context "when initialized with an upper tier registration" do
        let(:registration) { build(:registration, :has_required_data, :expires_later) }

        subject(:check_service) { described_class.new(registration) }

        it ":expiry_date is within 1 hour of the registration's" do
          expect(check_service.expiry_date).to be_within(1.hour).of(registration.expires_on)
        end
      end

      context "when the registration was created in BST and expires in GMT" do
        subject(:check_service) { described_class.new(bst_registration) }

        # Registration is made during British Summer Time (BST)
        # UK local time is 00:30 on 28 March 2017
        # UTC time is 23:30 on 27 March 2017
        # Registration should expire on 28 March 2020
        it ":expiry_date is an hour ahead of the expires_on date to compensate" do
          expect(check_service.expiry_date).to eq(bst_registration.expires_on + 1.hour)
        end
      end

      context "when the registration was created in GMT and expires in BST" do
        subject(:check_service) { described_class.new(gmt_registration) }

        # Registration is made during Greenwich Mean Time (GMT).
        # UK local time & UTC are both 23:30 on 27 October 2015
        # Registration should expire on 27 October 2018
        it ":expiry_date is an hour behind the expires_on date to compensate" do
          expect(check_service.expiry_date).to eq(gmt_registration.expires_on - 1.hour)
        end
      end

      context "when initialized with nil" do
        it "raises an error" do
          expect { described_class.new(nil) }.to raise_error("ExpiryCheckService expects a registration")
        end
      end

      context "when initialized with lower tier registration" do
        let(:registration) { build(:registration, :has_required_data, :lower_tier) }

        subject(:check_service) { described_class.new(registration) }

        it ":expiry_date is nil" do
          expect(check_service.expiry_date).to be_nil
        end
      end
    end

    describe "#date_can_renew_from" do
      context "when the renewal window is 3 months and the registration provided expires on 2018-03-25" do
        before do
          allow(Rails.configuration).to receive(:renewal_window).and_return(3)
        end

        let(:registration) { build(:registration, :has_required_data, expires_on: Date.new(2018, 3, 25)) }

        subject(:check_service) { described_class.new(registration) }

        it "returns a date of 2017-12-25" do
          expect(check_service.date_can_renew_from).to eq(Date.new(2017, 12, 25))
        end
      end
    end

    describe "#expiry_date_after_renewal" do
      context "when the registration duration is 3 years and the registration provided expires on 2018-03-25" do
        before do
          allow(Rails.configuration).to receive(:expires_after).and_return(3)
        end

        let(:registration) { build(:registration, :has_required_data, expires_on: Date.new(2018, 3, 25)) }

        subject(:check_service) { described_class.new(registration) }

        it "returns a date of 2021-03-25" do
          expect(check_service.expiry_date_after_renewal).to eq(Date.new(2021, 3, 25))
        end
      end
    end

    describe "#expired?" do
      context "when the registration expired yesterday" do
        let(:registration) { build(:registration, :has_required_data, expires_on: Date.yesterday) }

        subject(:check_service) { described_class.new(registration) }

        it "is expired" do
          expect(check_service.expired?).to be true
        end
      end

      context "when the registration expires today" do
        let(:registration) { build(:registration, :has_required_data, expires_on: Date.today) }

        subject(:check_service) { described_class.new(registration) }

        it "is expired" do
          expect(check_service.expired?).to be true
        end
      end

      context "when the registration expires tomorrow" do
        let(:registration) { build(:registration, :has_required_data, expires_on: Date.tomorrow) }

        subject(:check_service) { described_class.new(registration) }

        it "is not expired" do
          expect(check_service.expired?).to be false
        end
      end

      context "when the registration was created in BST and expires in GMT" do
        subject(:check_service) { described_class.new(bst_registration) }

        it "does not expire a day early due to the time difference" do
          # Skip ahead to the end of the last day the reg should be active
          Timecop.freeze(Time.find_zone("London").local(2020, 3, 27, 23, 59)) do
            # GMT is now in effect (not BST)
            # UK local time & UTC are both 23:59 on 27 March 2020
            expect(check_service.expired?).to be false
          end
        end
      end

      context "when the registration was created in GMT and expires in BST" do
        subject(:check_service) { described_class.new(gmt_registration) }

        it "does not expire a day early due to the time difference" do
          # Skip ahead to the end of the last day the reg should be active
          Timecop.freeze(Time.find_zone("London").local(2018, 10, 26, 23, 59)) do
            # BST is now in effect (not GMT)
            # UK local time is 23:59 on 26 October 2018
            # UTC time is 22:59 on 26 October 2018
            expect(check_service.expired?).to be false
          end
        end
      end
    end

    describe "#in_renewal_window?" do
      context "when the renewal window is 3 months" do
        before do
          allow(Rails.configuration).to receive(:renewal_window).and_return(3)
        end

        context "when the expiry date is 3 months and 2 days from today" do
          let(:registration) { build(:registration, :has_required_data, expires_on: 3.months.from_now + 2.day) }

          subject(:check_service) { described_class.new(registration) }

          it "is not in the window" do
            expect(check_service.in_renewal_window?).to be false
          end
        end

        context "when the expiry date is 3 months and 1 day from today" do
          let(:registration) { build(:registration, :has_required_data, expires_on: 3.months.from_now + 1.day) }

          subject(:check_service) { described_class.new(registration) }

          it "is not in the window" do
            expect(check_service.in_renewal_window?).to be false
          end
        end

        context "when the expiry date is 3 months from today" do
          let(:registration) { build(:registration, :has_required_data, expires_on: 3.months.from_now) }

          subject(:check_service) { described_class.new(registration) }

          it "is in the window" do
            expect(check_service.in_renewal_window?).to be true
          end
        end

        context "when the expiry date is less than 3 months from today" do
          let(:registration) { build(:registration, :has_required_data, expires_on: 3.months.from_now - 1.day) }

          subject(:check_service) { described_class.new(registration) }

          it "is in the window" do
            expect(check_service.in_renewal_window?).to be true
          end
        end
      end
    end

    describe "#in_expiry_grace_window?" do
      let(:last_day) { Date.current }
      let(:registration) { build(:registration, :has_required_data, expires_on: expires_on) }

      subject(:check_service) { described_class.new(registration) }

      before do
        allow(LastDayOfGraceWindowService).to receive(:run).with(registration: registration, ignore_extended_grace_window: false).and_return(last_day)
      end

      context "when the current day is before the expiry date" do
        let(:expires_on) { 2.days.from_now }

        it "returns false" do
          expect(check_service.in_expiry_grace_window?).to be false
        end
      end

      context "when the current day is on the expiry date" do
        let(:expires_on) { Time.now }

        it "returns true" do
          expect(check_service.in_expiry_grace_window?).to be true
        end
      end

      context "when the current day is after the expiry date" do
        let(:expires_on) { 2.days.ago }

        context "when the current day is before the last grace window day" do
          let(:last_day) { 1.day.from_now }

          it "returns true" do
            expect(check_service.in_expiry_grace_window?).to be true
          end
        end

        context "when the current day is on the last grace window day" do
          let(:last_day) { Date.current }

          it "returns true" do
            expect(check_service.in_expiry_grace_window?).to be true
          end
        end

        context "when the current day is after the last grace window day" do
          let(:last_day) { 1.day.ago }

          it "returns false" do
            expect(check_service.in_expiry_grace_window?).to be false
          end
        end
      end
    end
  end
end
