# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CompaniesHouseStatusService do
    describe ".permitted_status?" do
      %i[active voluntary-arrangement liquidation].each do |status|
        it "allows #{status}" do
          expect(described_class.permitted_status?(status)).to be true
        end
      end

      it "allows string status values" do
        expect(described_class.permitted_status?("liquidation")).to be true
      end

      it "rejects other company statuses" do
        expect(described_class.permitted_status?(:dissolved)).to be false
      end
    end
  end
end
