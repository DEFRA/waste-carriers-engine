# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe Registration, type: :model do
    describe "#reg_identifier" do
      context "when a registration has no reg_identifier" do
        let(:registration) { build(:registration, :has_required_data) }
        before(:each) { registration.tier = nil }

        it "is not valid" do
          expect(registration).to_not be_valid
        end
      end

      context "when a registration has the same reg_identifier as another registration" do
        let(:registration_a) { create(:registration, :has_required_data) }
        let(:registration_b) { create(:registration, :has_required_data) }

        before(:each) { registration_b.reg_identifier = registration_a.reg_identifier }

        it "is not valid" do
          expect(registration_b).to_not be_valid
        end
      end
    end

    describe "scopes" do
      describe ".active" do
        it "returns active registrations" do
          active_registration = create(:registration, :has_required_data, :is_active)
          revoked_registration = create(:registration, :has_required_data, :is_revoked)

          result = described_class.active

          expect(result).to include(active_registration)
          expect(result).to_not include(revoked_registration)
        end
      end

      describe ".active_and_expired" do
        it "returns active and expired registrations" do
          active = create(:registration, :has_required_data, :is_active)
          expired = create(:registration, :has_required_data, :is_expired)
          revoked = create(:registration, :has_required_data, :is_revoked)

          result = described_class.active_and_expired

          expect(result).to include(active)
          expect(result).to include(expired)
          expect(result).to_not include(revoked)
        end
      end

      describe ".in_grace_window" do
        it "returns registrations whose expired date is in the grace window" do
          allow(Rails.configuration).to receive(:grace_window).and_return(3)

          future_expire_date = create(:registration, :has_required_data, expires_on: 2.days.from_now)
          past_in_grace_window = create(:registration, :has_required_data, expires_on: 1.day.ago)
          edge_grace_window = create(:registration, :has_required_data, expires_on: 3.day.ago)
          past_not_in_grace_window = create(:registration, :has_required_data, expires_on: 4.day.ago)

          result = described_class.in_grace_window

          expect(result).to include(future_expire_date)
          expect(result).to include(past_in_grace_window)
          expect(result).to_not include(edge_grace_window)
          expect(result).to_not include(past_not_in_grace_window)
        end
      end

      describe ".expired_at_end_of_today" do
        it "returns registrations that have expired at the end of current day" do
          expired_registration = create(:registration, :has_required_data, expires_on: Time.now.beginning_of_day + 4.hours)
          active_registration = create(:registration, :has_required_data, expires_on: Time.now.end_of_day + 4.hours)

          result = described_class.expired_at_end_of_today

          expect(result).to include(expired_registration)
          expect(result).to_not include(active_registration)
        end
      end

      describe ".upper_tier" do
        it "returns upper tier registrations" do
          upper_tier_registration = create(:registration, :has_required_data, tier: "UPPER")
          lower_tier_registration = create(:registration, :has_required_data, tier: "LOWER")

          result = described_class.upper_tier

          expect(result).to include(upper_tier_registration)
          expect(result).to_not include(lower_tier_registration)
        end
      end
    end

    describe "#generate_renew_token" do
      let(:registration) { create(:registration, :has_required_data) }

      it "generates a renew token and assign it to the registration every time it is called" do
        old_renew_token = registration.renew_token

        registration.generate_renew_token!

        expect(registration.renew_token).to be_present
        expect(registration.renew_token).to_not eq(old_renew_token)

        old_renew_token = registration.renew_token

        registration.generate_renew_token!

        expect(registration.renew_token).to_not eq(old_renew_token)
      end
    end

    describe "#expire!" do
      it "update the registration status to expired" do
        registration = create(:registration, :is_active, :has_required_data)

        registration.expire!

        expect(registration).to be_expired
      end
    end

    describe "#tier" do
      context "when a registration has no tier" do
        let(:registration) { build(:registration, :has_required_data, tier: nil) }

        it "is not valid" do
          expect(registration).to_not be_valid
        end
      end

      context "when a registration has 'UPPER' as a tier" do
        let(:registration) { build(:registration, :has_required_data, tier: "UPPER") }

        it "is valid" do
          expect(registration).to be_valid
        end
      end

      context "when a registration has 'LOWER' as a tier" do
        let(:registration) { build(:registration, :has_required_data, tier: "LOWER") }

        it "is valid" do
          expect(registration).to be_valid
        end
      end

      context "when a registration has an invalid string as a tier" do
        let(:registration) { build(:registration, :has_required_data, tier: "foo") }

        it "is not valid" do
          expect(registration).to_not be_valid
        end
      end
    end

    describe "#address" do
      context "when a registration has one address" do
        let(:address) { build(:address, :has_required_data) }
        let(:registration) do
          build(:registration,
                :has_required_data,
                addresses: [address])
        end

        it "is valid" do
          expect(registration).to be_valid
        end
      end

      context "when a registration has multiple addresses" do
        let(:address_a) { build(:address, :has_required_data) }
        let(:address_b) { build(:address, :has_required_data) }
        let(:registration) do
          build(:registration,
                :has_required_data,
                addresses: [address_a,
                            address_b])
        end

        it "is valid" do
          expect(registration).to be_valid
        end
      end

      context "when a registration has no addresses" do
        let(:registration) { build(:registration, :has_required_data, addresses: []) }

        it "is not valid" do
          expect(registration).to_not be_valid
        end
      end

      context "when registration has an address which has a location" do
        let(:location) { build(:location) }
        let(:address) { build(:address, :has_required_data, location: location) }
        let(:registration) do
          build(:registration,
                :has_required_data,
                addresses: [address])
        end

        it "is valid" do
          expect(registration).to be_valid
        end
      end
    end

    describe "#conviction_search_result" do
      context "when a registration has a conviction_search_result" do
        let(:conviction_search_result) { build(:conviction_search_result) }
        let(:registration) do
          build(:registration,
                :has_required_data,
                conviction_search_result: conviction_search_result)
        end

        it "is valid" do
          expect(registration).to be_valid
        end
      end
    end

    describe "#convictionSignOffs" do
      context "when a registration has one conviction_sign_off" do
        let(:conviction_sign_off) { build(:conviction_sign_off) }
        let(:registration) do
          build(:registration,
                :has_required_data,
                conviction_sign_offs: [conviction_sign_off])
        end

        it "is valid" do
          expect(registration).to be_valid
        end
      end
    end

    describe "#finance_details" do
      context "when a registration has a finance_details" do
        let(:finance_details) { build(:finance_details, :has_required_data) }
        let(:registration) do
          build(:registration,
                :has_required_data,
                finance_details: finance_details)
        end

        it "is valid" do
          expect(registration).to be_valid
        end
      end

      describe "#balance" do
        context "when a registration has a finance_details which has no balance" do
          let(:finance_details) { build(:finance_details, balance: nil) }
          let(:registration) do
            build(:registration,
                  :has_required_data,
                  finance_details: finance_details)
          end

          it "is not valid" do
            expect(registration).to_not be_valid
          end
        end
      end

      describe "#orders" do
        context "when a registration has a finance_details which has one order" do
          let(:order) { build(:order) }
          let(:finance_details) { build(:finance_details, :has_required_data, orders: [order]) }
          let(:registration) do
            build(:registration,
                  :has_required_data,
                  finance_details: finance_details)
          end

          it "is valid" do
            expect(registration).to be_valid
          end
        end

        context "when a registration has a finance_details which has multiple orders" do
          let(:order_a) { build(:order) }
          let(:order_b) { build(:order) }
          let(:finance_details) { build(:finance_details, :has_required_data, orders: [order_a, order_b]) }
          let(:registration) do
            build(:registration,
                  :has_required_data,
                  finance_details: finance_details)
          end

          it "is valid" do
            expect(registration).to be_valid
          end
        end

        describe "#order_items" do
          context "when a registration has a finance_details which has an order which has an order_item" do
            let(:order_item) { build(:order_item) }
            let(:order) { build(:order, order_items: [order_item]) }
            let(:finance_details) { build(:finance_details, :has_required_data, orders: [order]) }
            let(:registration) do
              build(:registration,
                    :has_required_data,
                    finance_details: finance_details)
            end

            it "is valid" do
              expect(registration).to be_valid
            end
          end

          context "when a registration has a finance_details which has an order which has multiple order_items" do
            let(:order_item_a) { build(:order_item) }
            let(:order_item_b) { build(:order_item) }
            let(:order) { build(:order, order_items: [order_item_a, order_item_b]) }
            let(:finance_details) { build(:finance_details, :has_required_data, orders: [order]) }
            let(:registration) do
              build(:registration,
                    :has_required_data,
                    finance_details: finance_details)
            end

            it "is valid" do
              expect(registration).to be_valid
            end
          end
        end
      end

      describe "#payments" do
        context "when a registration has a finance_details which has one payment" do
          let(:payment) { build(:payment) }
          let(:finance_details) { build(:finance_details, :has_required_data, payments: [payment]) }
          let(:registration) do
            build(:registration,
                  :has_required_data,
                  finance_details: finance_details)
          end

          it "is valid" do
            expect(registration).to be_valid
          end
        end

        context "when a registration has a finance_details which has multiple payments" do
          let(:payment_a) { build(:payment) }
          let(:payment_b) { build(:payment) }
          let(:finance_details) { build(:finance_details, :has_required_data, payments: [payment_a, payment_b]) }
          let(:registration) do
            build(:registration,
                  :has_required_data,
                  finance_details: finance_details)
          end

          it "is valid" do
            expect(registration).to be_valid
          end
        end
      end
    end

    describe "#key_people" do
      context "when a registration has one key person" do
        let(:key_person) { build(:key_person, :has_required_data) }
        let(:registration) do
          build(:registration,
                :has_required_data,
                key_people: [key_person])
        end

        it "is valid" do
          expect(registration).to be_valid
        end
      end

      context "when a registration has multiple key people" do
        let(:key_person_a) { build(:key_person, :has_required_data) }
        let(:key_person_b) { build(:key_person, :has_required_data) }
        let(:registration) do
          build(:registration,
                :has_required_data,
                key_people: [key_person_a,
                             key_person_b])
        end

        it "is valid" do
          expect(registration).to be_valid
        end
      end

      describe "#conviction_search_result" do
        context "when a registration's key person has a conviction_search_result" do
          let(:conviction_search_result) { build(:conviction_search_result) }
          let(:key_person) { build(:key_person, :has_required_data, conviction_search_result: conviction_search_result) }
          let(:registration) do
            build(:registration,
                  :has_required_data,
                  key_people: [key_person])
          end

          it "is valid" do
            expect(registration).to be_valid
          end
        end
      end
    end

    describe "#metaData" do
      context "when a registration has no metaData" do
        let(:registration) { build(:registration, :has_required_data, metaData: nil) }

        it "is not valid" do
          expect(registration).to_not be_valid
        end
      end

      describe "#status" do
        context "when a registration is created" do
          let(:meta_data) { build(:metaData) }
          let(:registration) { build(:registration, :has_required_data, metaData: meta_data) }

          it "has 'pending' status" do
            expect(registration.metaData).to have_state(:PENDING)
          end

          it "is not valid without a status" do
            registration.metaData.status = nil
            expect(registration).to_not be_valid
          end
        end

        context "when a registration is pending" do
          let(:registration) { build(:registration, :is_pending) }

          it "has 'pending' status" do
            expect(registration.metaData).to have_state(:PENDING)
          end

          it "can be activated" do
            expect(registration.metaData).to allow_event :activate
            expect(registration.metaData).to transition_from(:PENDING).to(:ACTIVE).on_event(:activate)
          end

          it "can be refused" do
            expect(registration.metaData).to allow_event :refuse
            expect(registration.metaData).to transition_from(:PENDING).to(:REFUSED).on_event(:refuse)
          end

          it "cannot be revoked" do
            expect(registration.metaData).to_not allow_event :revoke
          end

          it "cannot be renewed" do
            expect(registration.metaData).to_not allow_event :renew
          end

          it "cannot expire" do
            expect(registration.metaData).to_not allow_event :expire
          end

          it "cannot transition to 'revoked', 'renewed' or 'expired'" do
            expect(registration.metaData).to_not allow_transition_to(:REVOKED)
            expect(registration.metaData).to_not allow_transition_to(:renewed)
            expect(registration.metaData).to_not allow_transition_to(:EXPIRED)
          end
        end

        context "when a registration is activated" do
          let(:registration) { create(:registration, :has_required_data, :is_pending) }

          before { allow(Rails.configuration).to receive(:expires_after).and_return(3) }

          it "sets expires_on 3 years in the future" do
            expect(registration.expires_on).to be_nil

            registration.metaData.activate!

            # Use .to_i to ignore milliseconds when comparing time
            expect(registration.reload.expires_on.to_i).to eq(3.years.from_now.to_i)
          end
        end

        context "when a registration is active" do
          let(:registration) { build(:registration, :expires_later, :is_active) }

          it "has 'active' status" do
            expect(registration.metaData).to have_state(:ACTIVE)
          end

          it "can be revoked" do
            expect(registration.metaData).to allow_event :revoke
            expect(registration.metaData).to transition_from(:ACTIVE).to(:REVOKED).on_event(:revoke)
          end

          it "can expire" do
            expect(registration.metaData).to allow_event :expire
            expect(registration.metaData).to transition_from(:ACTIVE).to(:EXPIRED).on_event(:expire)
          end

          it "cannot be refused" do
            expect(registration.metaData).to_not allow_event :refuse
          end

          it "cannot be activated" do
            expect(registration.metaData).to_not allow_event :activate
          end

          it "cannot transition to 'pending' or 'refused'" do
            expect(registration.metaData).to_not allow_transition_to(:PENDING)
            expect(registration.metaData).to_not allow_transition_to(:REFUSED)
          end
        end

        context "when a registration is refused" do
          let(:registration) { build(:registration, :is_refused) }

          it "has 'refused' status" do
            expect(registration.metaData).to have_state(:REFUSED)
          end

          it "cannot transition to other states" do
            expect(registration.metaData).to_not allow_transition_to(:PENDING)
            expect(registration.metaData).to_not allow_transition_to(:ACTIVE)
            expect(registration.metaData).to_not allow_transition_to(:REFUSED)
            expect(registration.metaData).to_not allow_transition_to(:REVOKED)
          end
        end

        context "when a registration is revoked" do
          let(:registration) { build(:registration, :is_revoked) }

          it "has 'revoked' status" do
            expect(registration.metaData).to have_state(:REVOKED)
          end

          it "cannot transition to other states" do
            expect(registration.metaData).to_not allow_transition_to(:PENDING)
            expect(registration.metaData).to_not allow_transition_to(:ACTIVE)
            expect(registration.metaData).to_not allow_transition_to(:REFUSED)
            expect(registration.metaData).to_not allow_transition_to(:REVOKED)
          end
        end

        context "when a registration is expired" do
          let(:registration) { build(:registration, :has_required_data, :is_expired, expires_on: 1.month.ago) }

          it "has 'expired' status" do
            expect(registration.metaData).to have_state(:EXPIRED)
          end

          it "cannot be revoked" do
            expect(registration.metaData).to_not allow_event :revoke
          end

          it "cannot be refused" do
            expect(registration.metaData).to_not allow_event :refuse
          end

          it "cannot expire" do
            expect(registration.metaData).to_not allow_event :expire
          end

          it "cannot transition to 'pending', 'refused', 'revoked'" do
            expect(registration.metaData).to_not allow_transition_to(:PENDING)
            expect(registration.metaData).to_not allow_transition_to(:REFUSED)
            expect(registration.metaData).to_not allow_transition_to(:REVOKED)
          end
        end
      end
    end

    describe "search" do
      it_should_behave_like "Search scopes",
                            record_class: WasteCarriersEngine::Registration,
                            factory: :registration
    end

    describe "#can_start_renewal?" do
      let(:registration) { build(:registration, :has_required_data) }

      context "when the registration is lower tier" do
        before { registration.tier = "LOWER" }

        it "returns false" do
          expect(registration.can_start_renewal?).to eq(false)
        end
      end

      context "when the registration is upper tier" do
        before { registration.tier = "UPPER" }

        context "when the registration has been revoked or refused" do
          before { registration.metaData.status = %w[REVOKED REFUSED].sample }

          it "returns false" do
            expect(registration.can_start_renewal?).to eq(false)
          end
        end

        context "when the registration has not been revoked or refused" do
          before { registration.metaData.status = "ACTIVE" }

          context "when the registration is in the grace window" do
            before { allow_any_instance_of(ExpiryCheckService).to receive(:in_expiry_grace_window?).and_return(true) }

            it "returns true" do
              expect(registration.can_start_renewal?).to eq(true)
            end
          end

          context "when the registration is not in the grace window" do
            before { allow_any_instance_of(ExpiryCheckService).to receive(:in_expiry_grace_window?).and_return(false) }

            context "when the registration is past the expiry date" do
              before { allow_any_instance_of(ExpiryCheckService).to receive(:expired?).and_return(true) }

              it "returns false" do
                expect(registration.can_start_renewal?).to eq(false)
              end
            end

            context "when the registration is not past the expiry date" do
              before { allow_any_instance_of(ExpiryCheckService).to receive(:expired?).and_return(false) }

              context "when the registration is in the renewal window" do
                before { allow_any_instance_of(ExpiryCheckService).to receive(:in_renewal_window?).and_return(true) }

                it "returns true" do
                  expect(registration.can_start_renewal?).to eq(true)
                end
              end

              context "when the result is not in the renewal window" do
                before { allow_any_instance_of(ExpiryCheckService).to receive(:in_renewal_window?).and_return(false) }

                it "returns false" do
                  expect(registration.can_start_renewal?).to eq(false)
                end
              end
            end
          end
        end
      end
    end

    describe "status" do
      it_should_behave_like "Can check registration status",
                            factory: :registration
    end

    describe "registration attributes" do
      it_should_behave_like "Can have registration attributes",
                            factory: :registration
    end

    describe "conviction scopes" do
      it_should_behave_like "Can filter conviction status"
    end
  end
end
