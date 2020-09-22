# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ExpiryDateService do
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

    describe "#run" do
      context "when initialized with an upper tier registration" do
        let(:registration) { build(:registration, :has_required_data, :expires_later) }

        it "returns an expiry date within 1 hour of the registration's" do
          expect(described_class.run(registration: registration)).to be_within(1.hour).of(registration.expires_on)
        end
      end

      context "when the registration was created in BST and expires in GMT" do
        # Registration is made during British Summer Time (BST)
        # UK local time is 00:30 on 28 March 2017
        # UTC time is 23:30 on 27 March 2017
        # Registration should expire on 28 March 2020
        it "returns a time 1 hour ahead of the expires_on date to compensate" do
          expect(described_class.run(registration: bst_registration)).to eq(bst_registration.expires_on + 1.hour)
        end
      end

      context "when the registration was created in GMT and expires in BST" do
        # Registration is made during Greenwich Mean Time (GMT).
        # UK local time & UTC are both 23:30 on 27 October 2015
        # Registration should expire on 27 October 2018
        it "returns a time 1 hour behind the expires_on date to compensate" do
          expect(described_class.run(registration: gmt_registration)).to eq(gmt_registration.expires_on - 1.hour)
        end
      end

      context "when the registration has no expiry date" do
        let(:registration) { build(:registration, :has_required_data) }

        it "returns nil" do
          expect(described_class.run(registration: registration)).to eq(nil)
        end
      end
    end
  end
end
