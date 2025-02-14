# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe DetailedLogger do

    before do
      allow(Rails.logger).to receive(:fatal)
      allow(Rails.logger).to receive(:error)
      allow(Rails.logger).to receive(:warn)
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:debug)
      allow(Rails.logger).to receive(:unknown)
    end

    context "when the feature toggle is not active" do
      before { allow(FeatureToggle).to receive(:active?).with(:detailed_logging).and_return(false) }

      shared_examples "does not write to the log" do |level|
        it do
          described_class.send(level.to_sym, "foo")

          expect(Rails.logger).not_to have_received(level)
        end
      end

      %i[fatal error warn info debug unknown].each do |level|
        it_behaves_like "does not write to the log", level
      end
    end

    context "when the feature toggle is active" do
      before { allow(FeatureToggle).to receive(:active?).with(:detailed_logging).and_return(true) }

      shared_examples "writes to the log" do |level|
        it do
          described_class.send(level.to_sym, "foo")

          expect(Rails.logger).to have_received(level)
        end
      end

      %i[fatal error warn info debug unknown].each do |level|
        it_behaves_like "writes to the log", level
      end
    end
  end
end
