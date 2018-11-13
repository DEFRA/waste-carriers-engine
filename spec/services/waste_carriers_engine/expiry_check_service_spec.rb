# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ExpiryCheckService do
    describe "#attributes" do

      context "when initialized with an upper tier registration" do
        let(:registration) { build(:registration, :has_required_data, :expires_later) }
        subject { ExpiryCheckService.new(registration) }

        it ":expiry_date matches the registration's" do
          expect(subject.expiry_date).to eq(registration.expires_on)
        end

        it ":registration_date matches the registration's" do
          expect(subject.registration_date).to eq(registration.metaData.date_registered)
        end
      end

      context "when the registration was created in BST and expires in GMT" do
        let!(:registration) do
          registration = build(:registration, :has_required_data)
          registration.metaData.date_registered = Time.find_zone("London").local(2017, 3, 28, 0, 30)
          registration.expires_on = registration.metaData.date_registered + 3.years
          registration
        end
        subject { ExpiryCheckService.new(registration) }

        # Registration is made during British Summer Time (BST)
        # UK local time is 00:30 on 28 March 2017
        # UTC time is 23:30 on 27 March 2017
        # Registration should expire on 28 March 2020
        it ":expiry_date is an hour ahead of the expires_on date to compensate" do
          expect(subject.expiry_date).to eq(registration.expires_on + 1.hour)
        end
      end

      context "when the registration was created in GMT and expires in BST" do
        let!(:registration) do
          registration = build(:registration, :has_required_data)
          registration.metaData.date_registered = Time.find_zone("London").local(2015, 10, 27, 23, 30)
          registration.expires_on = registration.metaData.date_registered + 3.years
          registration
        end
        subject { ExpiryCheckService.new(registration) }

        # Registration is made during Greenwich Mean Time (GMT).
        # UK local time & UTC are both 23:30 on 27 October 2015
        # Registration should expire on 27 October 2018
        it ":expiry_date is an hour behind the expires_on date to compensate" do
          expect(subject.expiry_date).to eq(registration.expires_on - 1.hour)
        end
      end

      context "when initialized with nil" do
        it "raises an error" do
          expect { ExpiryCheckService.new(nil) }.to raise_error("ExpiryCheckService expects a registration")
        end
      end

      context "when initialized with lower tier registration" do
        let(:registration) { build(:registration, :has_required_data) }
        subject { ExpiryCheckService.new(registration) }

        it ":expiry_date is set to the UTC epoch" do
          expect(subject.expiry_date).to eq(Date.new(1970, 1, 1))
        end

        it ":registration_date matches the registration's" do
          expect(subject.registration_date).to eq(registration.metaData.date_registered)
        end
      end
    end

    describe "#date_can_renew_from" do

      context "when the renewal window is 3 months and the registration provided expires on 2018-03-25" do
        before do
          allow(Rails.configuration).to receive(:renewal_window).and_return(3)
        end

        let(:registration) { build(:registration, :has_required_data, expires_on: Date.new(2018, 3, 25)) }
        subject { ExpiryCheckService.new(registration) }

        it "returns a date of 2017-12-25" do
          expect(subject.date_can_renew_from).to eq(Date.new(2017, 12, 25))
        end
      end

    end

    describe "#expired?" do

      context "when the registration expired yesterday" do
        let(:registration) { build(:registration, :has_required_data, expires_on: Date.yesterday) }
        subject { ExpiryCheckService.new(registration) }

        it "should be expired" do
          expect(subject.expired?).to eq(true)
        end
      end

      context "when the registration expires today" do
        let(:registration) { build(:registration, :has_required_data, expires_on: Date.today) }
        subject { ExpiryCheckService.new(registration) }

        it "should be expired" do
          expect(subject.expired?).to eq(true)
        end
      end

      context "when the registration expires tomorrow" do
        let(:registration) { build(:registration, :has_required_data, expires_on: Date.tomorrow) }
        subject { ExpiryCheckService.new(registration) }

        it "should not be expired" do
          expect(subject.expired?).to eq(false)
        end
      end

    end

    describe "#in_renewal_window?" do

      context "when the renewal window is 3 months" do
        before do
          allow(Rails.configuration).to receive(:renewal_window).and_return(3)
        end

        context "and the expiry date is 3 months and 2 days from today" do
          let(:registration) { build(:registration, :has_required_data, expires_on: 3.months.from_now + 2.day) }
          subject { ExpiryCheckService.new(registration) }

          it "should not be in the window" do
            expect(subject.in_renewal_window?).to eq(false)
          end
        end

        context "and the expiry date is 3 months and 1 day from today" do
          let(:registration) { build(:registration, :has_required_data, expires_on: 3.months.from_now + 1.day) }
          subject { ExpiryCheckService.new(registration) }

          it "should not be in the window" do
            expect(subject.in_renewal_window?).to eq(false)
          end
        end

        context "and the expiry date is 3 months from today" do
          let(:registration) { build(:registration, :has_required_data, expires_on: 3.months.from_now) }
          subject { ExpiryCheckService.new(registration) }

          it "should be in the window" do
            expect(subject.in_renewal_window?).to eq(true)
          end
        end

        context "and the expiry date is less than 3 months from today" do
          let(:registration) { build(:registration, :has_required_data, expires_on: 3.months.from_now - 1.day) }
          subject { ExpiryCheckService.new(registration) }

          it "should be in the window" do
            expect(subject.in_renewal_window?).to eq(true)
          end
        end
      end
    end

    describe "#in_expiry_grace_window?" do
      # You have to use let! to ensure it is not lazy-evaluated. If it is
      # it will be called inside the Timecop.freeze methods listed below
      # which means Date.today will evaluate to the date Timecop is freezing.
      # This leads to false positives for some tests, and a fail for the outside
      # renewal window.
      let!(:registration) { build(:registration, :has_required_data, expires_on: Date.today) }

      context "when the grace window is 3 days" do
        before { allow(Rails.configuration).to receive(:grace_window).and_return(3) }

        subject { ExpiryCheckService.new(registration) }

        context "and the current date is within the window" do
          it "returns true" do
            Timecop.freeze((Date.today + 3.days) - 1.day) do
              expect(subject.in_expiry_grace_window?).to eq(true)
            end
          end
        end

        context "and the current date is outside the window" do
          it "returns false" do
            Timecop.freeze(Date.today + 3.days) do
              expect(subject.in_expiry_grace_window?).to eq(false)
            end
          end
        end
      end

      context "when there is no grace window" do
        before { allow(Rails.configuration).to receive(:grace_window).and_return(0) }

        subject { ExpiryCheckService.new(registration) }

        it "returns false" do
          Timecop.freeze(Date.today + 3.days) do
            expect(subject.in_expiry_grace_window?).to eq(false)
          end
        end
      end
    end
  end
end
