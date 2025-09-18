# frozen_string_literal: true

require "rails_helper"

class RegistrableTest
  include WasteCarriersEngine::CanHaveDeregistrationToken

  def active?; end
end

module WasteCarriersEngine
  RSpec.describe "CanHaveDeregistrationToken" do

    before { allow(registrable).to receive(:active?).and_return(true) }

    subject(:registrable) { RegistrableTest.new }

    describe "#generate_deregistration_token" do

      context "with no existing deregistration token" do
        it "creates a token" do
          expect { registrable.generate_deregistration_token }.to change(registrable, :deregistration_token).from(nil)
        end

        it "sets the token timestamp" do
          expect { registrable.generate_deregistration_token }.to change(registrable, :deregistration_token_created_at).from(nil)
        end

        it "returns the token" do
          expect(registrable.generate_deregistration_token).to eq registrable.deregistration_token
        end
      end

      context "with an existing deregistration token" do
        before { Timecop.freeze(1.day.ago { registrable.generate_deregistration_token }) }

        it "updates the token" do
          expect { registrable.generate_deregistration_token }.to change(registrable, :deregistration_token)
        end

        it "updates the token timestamp" do
          expect { registrable.generate_deregistration_token }.to change(registrable, :deregistration_token_created_at)
        end
      end
    end

    describe "#deregistration_token_valid?" do
      let(:token_expiry_days) { 7 }

      before do
        allow(ENV).to receive(:fetch).with("WCRS_DEREGISTRATION_TOKEN_VALIDITY", any_args).and_return(token_expiry_days.to_s)
      end

      context "with no deregistration token" do
        it "returns false" do
          expect(registrable.deregistration_token_valid?).to be false
        end
      end

      context "with a deregistration token" do
        let(:token_created_at) { 1.day.ago }

        before { Timecop.freeze(token_created_at) { registrable.generate_deregistration_token } }

        context "with an expired deregistration token" do
          let(:token_created_at) { 6.months.ago }

          it "returns false" do
            expect(registrable.deregistration_token_valid?).to be false
          end
        end

        context "with a deregistration token expiring earlier today" do
          let(:token_created_at) { token_expiry_days.days.ago - 1.hour }

          it "returns false" do
            expect(registrable.deregistration_token_valid?).to be false
          end
        end

        context "with a deregistration token expiring later today" do
          let(:token_created_at) { token_expiry_days.days.ago + 1.hour }

          it "returns true" do
            expect(registrable.deregistration_token_valid?).to be true
          end
        end

        context "with a valid unexpired deregistration token" do
          it "returns true" do
            expect(registrable.deregistration_token_valid?).to be true
          end
        end

        context "when the registration is not active" do
          before { allow(registrable).to receive(:active?).and_return false }

          it "returns false" do
            expect(registrable.deregistration_token_valid?).to be false
          end
        end
      end
    end
  end
end
