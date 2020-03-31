# frozen_string_literal: true

require "rails_helper"

module Test
  RenewalLookupValidatable = Struct.new(:temp_lookup_number) do
    include ActiveModel::Validations

    attr_reader :temp_lookup_number
    validates_with WasteCarriersEngine::RenewalLookupValidator
  end
end

module WasteCarriersEngine
  RSpec.describe RenewalLookupValidator do
    subject { Test::RenewalLookupValidatable.new }

    context "when there is no matching registration" do
      before do
        expect(Registration).to receive(:where).and_return(nil)
      end

      it "is invalid and sets the correct error message" do
        expect(subject).to receive_message_chain(:errors, :add).with(:temp_lookup_number, :no_match)
        expect(subject).to_not be_valid
      end
    end

    context "when there is a matching registration" do
      let(:upper_tier) {}
      let(:active) {}
      let(:expired) {}
      let(:registration) do
        double(:registration,
               active?: active,
               expired?: expired,
               upper_tier?: upper_tier)
      end

      before do
        expect(Registration).to receive(:where).and_return([registration])
      end

      context "when it's lower tier" do
        let(:upper_tier) { false }

        it "is invalid and sets the correct error message" do
          expect(subject).to receive_message_chain(:errors, :add).with(:temp_lookup_number, :lower_tier)
          expect(subject).to_not be_valid
        end
      end

      context "when it's upper tier" do
        let(:upper_tier) { true }

        let(:date_can_renew_from) {}
        let(:expired_check_service) {}
        let(:in_expiry_grace_window) {}
        let(:in_renewal_window) {}

        let(:check_service) do
          double(:check_service,
                 date_can_renew_from: date_can_renew_from,
                 expired?: expired_check_service,
                 in_expiry_grace_window?: in_expiry_grace_window,
                 in_renewal_window?: in_renewal_window)
        end

        context "when the registration is active" do
          let(:active) { true }
          let(:expired) { false }
          let(:expired_check_service) { false }

          before do
            expect(ExpiryCheckService).to receive(:new).and_return(check_service)
          end

          context "when it's not yet in the renewal window" do
            let(:in_renewal_window) { false }

            it "is invalid and sets the correct error message" do
              expect(subject).to receive_message_chain(:errors, :add).with(:temp_lookup_number, :not_yet_renewable, date_can_renew_from)
              expect(subject).to_not be_valid
            end
          end

          context "when it's within the renewal window" do
            let(:in_renewal_window) { true }

            it "is valid" do
              expect(subject).to be_valid
            end
          end
        end

        context "when the registration is expired" do
          let(:active) { false }
          let(:expired) { true }
          let(:expired_check_service) { true }

          before do
            expect(ExpiryCheckService).to receive(:new).and_return(check_service)
          end

          context "when it's beyond the expiry grace period" do
            let(:expired_check_service) { false }

            it "is invalid and sets the correct error message" do
              expect(subject).to receive_message_chain(:errors, :add).with(:temp_lookup_number, :expired)
              expect(subject).to_not be_valid
            end
          end

          context "when it's within the expiry grace period" do
            let(:expired_check_service) { true }

            it "is valid" do
              expect(subject).to be_valid
            end
          end
        end

        context "when the registration is neither active nor expired" do
          let(:active) { false }
          let(:expired) { false }

          it "is invalid and sets the correct error message" do
            expect(subject).to receive_message_chain(:errors, :add).with(:temp_lookup_number, :unrenewable_status)
            expect(subject).to_not be_valid
          end
        end
      end
    end
  end
end
