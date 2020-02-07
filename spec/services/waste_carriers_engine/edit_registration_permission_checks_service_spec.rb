# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditRegistrationPermissionChecksService do
    let(:transient_registration) { double(:transient_registration) }
    let(:user) { double(:user) }
    let(:result) { double(:result) }
    let(:params) { { transient_registration: transient_registration, user: user } }

    describe ".run" do
      before do
        expect(transient_registration).to receive(:valid?).and_return(valid)
        expect(PermissionChecksResult).to receive(:new).and_return(result)
      end

      context "when the transient registration is not valid" do
        let(:valid) { false }

        it "returns an invalid result" do
          expect(result).to receive(:invalid!)

          expect(described_class.run(params)).to eq(result)
        end
      end

      context "when the transient registration is valid" do
        let(:valid) { true }
        let(:registration) { double(:registration) }
        let(:ability) { double(:ability) }

        before do
          allow(transient_registration).to receive(:registration).and_return(registration)

          expect(Ability).to receive(:new).with(user).and_return(ability)
          expect(ability).to receive(:can?).with(:edit, registration).and_return(can)
        end

        context "when the user does not have the correct permissions" do
          let(:can) { false }

          it "returns a missing permissions result" do
            expect(result).to receive(:needs_permissions!)

            expect(described_class.run(params)).to eq(result)
          end
        end

        context "when the user has the correct permissions" do
          let(:can) { true }
          let(:registration) { double(:registration) }

          before do
            allow(transient_registration).to receive(:registration).and_return(registration)

            expect(registration).to receive(:active?).and_return(active)
          end

          context "when the registration is not active" do
            let(:active) { false }

            it "returns an invalid result" do
              expect(result).to receive(:invalid!)

              expect(described_class.run(params)).to eq(result)
            end
          end

          context "when the registration is active" do
            let(:active) { true }

            it "returns a pass result" do
              expect(result).to receive(:pass!)

              expect(described_class.run(params)).to eq(result)
            end
          end
        end
      end
    end
  end
end
