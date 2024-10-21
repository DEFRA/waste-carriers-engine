# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistrationPermissionChecksService do

    before do
      allow(transient_registration).to receive(:valid?).and_return(valid)
      allow(PermissionChecksResult).to receive(:new).and_return(result)
    end

    describe ".run" do
      let(:transient_registration) { instance_double(RenewingRegistration, from_magic_link: false) }
      let(:result) { instance_double(PermissionChecksResult) }
      let(:params) { { transient_registration: transient_registration } }

      before do
        allow(result).to receive(:invalid!)
        allow(result).to receive(:needs_permissions!)
        allow(result).to receive(:pass!)
        allow(result).to receive(:unrenewable!)
      end

      context "when the transient registration is not valid" do
        let(:valid) { false }

        it "returns an invalid result" do
          expect(described_class.run(params)).to eq(result)

          expect(result).to have_received(:invalid!)
        end
      end

      context "when the transient registration is valid" do
        let(:valid) { true }
        let(:registration) { instance_double(Registration) }
        let(:ability) { instance_double(Ability) }

        before do
          allow(transient_registration).to receive(:registration).and_return(registration)
          allow(transient_registration).to receive(:registration).and_return(registration)
          allow(transient_registration).to receive(:can_be_renewed?).and_return(renewable)
        end

        context "when the transient_registration cannot be renewed" do
          let(:renewable) { false }

          it "returns an unrenewable result" do
            expect(described_class.run(params)).to eq(result)

            expect(result).to have_received(:unrenewable!)
          end
        end

        context "when the transient_registration is renewable" do
          let(:renewable) { true }

          context "when the transient registration is accessed through a magic link" do
            let(:transient_registration) { instance_double(RenewingRegistration, from_magic_link: true) }

            it "returns a pass result" do
              expect(described_class.run(params)).to eq(result)

              expect(result).to have_received(:pass!)
            end
          end

          it "returns a pass result" do
            expect(described_class.run(params)).to eq(result)

            expect(result).to have_received(:pass!)
          end
        end
      end
    end
  end
end
