# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistrationPermissionChecksService do
    let(:transient_registration) { double(:transient_registration, from_magic_link: false) }
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
          expect(ability).to receive(:can?).with(:update, transient_registration).and_return(can)
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

            expect(transient_registration).to receive(:can_be_renewed?).and_return(renewable)
          end

          context "when the transient_registration cannot be renewed" do
            let(:renewable) { false }

            it "returns an unrenewable result" do
              expect(result).to receive(:unrenewable!)

              expect(described_class.run(params)).to eq(result)
            end
          end

          context "when the transient_registration is renewable" do
            let(:renewable) { true }

            context "when the transient registration is accessed through a magic link" do
              let(:transient_registration) { double(:transient_registration, from_magic_link: true) }

              it "returns a pass result" do
                expect(result).to receive(:pass!)

                expect(described_class.run(params)).to eq(result)
              end
            end

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
