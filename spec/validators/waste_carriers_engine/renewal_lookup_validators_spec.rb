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
    subject(:validatable) { Test::RenewalLookupValidatable.new }

    context "when there is no matching registration" do
      before do
        allow(Registration).to receive(:where).and_return([])
      end

      it "is invalid and sets the correct error message" do
        expect(validatable).not_to be_valid
        expect(validatable.errors[:temp_lookup_number].first).to include("no_match")
      end
    end

    context "when there is a matching registration" do
      let(:upper_tier) { false }
      let(:active) { false }
      let(:expired) { false }
      let(:registration) do
        instance_double(Registration,
                        active?: active,
                        expired?: expired,
                        upper_tier?: upper_tier)
      end

      before do
        allow(Registration).to receive(:where).and_return([registration])
      end

      context "when it's lower tier" do
        let(:upper_tier) { false }

        it "is invalid and sets the correct error message" do
          expect(validatable).not_to be_valid
          expect(validatable.errors[:temp_lookup_number].first).to include("lower_tier")
        end
      end

      context "when it's upper tier" do
        let(:upper_tier) { true }

        let(:date_can_renew_from) { nil }
        let(:expired_check_service) { nil }
        let(:in_expiry_grace_window) { false }
        let(:in_renewal_window) { false }

        let(:check_service) do
          instance_double(ExpiryCheckService,
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
            allow(ExpiryCheckService).to receive(:new).and_return(check_service)
          end

          context "when it's not yet in the renewal window" do
            let(:in_renewal_window) { false }

            it "is invalid and sets the correct error message" do
              expect(validatable).not_to be_valid
              expect(validatable.errors[:temp_lookup_number].first).to include("not_yet_renewable")
            end
          end

          context "when it's within the renewal window" do
            let(:in_renewal_window) { true }

            it "is valid" do
              expect(validatable).to be_valid
            end
          end
        end

        context "when the registration is expired" do
          let(:active) { false }
          let(:expired) { true }
          let(:expired_check_service) { true }

          before do
            allow(ExpiryCheckService).to receive(:new).and_return(check_service)
          end

          context "when it's beyond the expiry grace period" do
            let(:in_expiry_grace_window) { false }

            it "is invalid and sets the correct error message" do
              expect(validatable).not_to be_valid
              expect(validatable.errors[:temp_lookup_number].first).to include("expired")
            end
          end

          context "when it's within the expiry grace period" do
            let(:in_expiry_grace_window) { true }

            it "is valid" do
              expect(validatable).to be_valid
            end
          end
        end

        context "when the registration is neither active nor expired" do
          let(:active) { false }
          let(:expired) { false }

          it "is invalid and sets the correct error message" do
            expect(validatable).not_to be_valid
            expect(validatable.errors[:temp_lookup_number].first).to include("unrenewable_status")
          end
        end
      end
    end
  end
end
