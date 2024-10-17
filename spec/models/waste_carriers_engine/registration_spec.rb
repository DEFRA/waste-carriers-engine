# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe Registration do
    describe "#reg_identifier" do
      context "when a registration has no reg_identifier" do
        let(:registration) { build(:registration, :has_required_data) }

        before { registration.tier = nil }

        it "is not valid" do
          expect(registration).not_to be_valid
        end
      end

      context "when a registration has the same reg_identifier as another registration" do
        let(:registration_a) { create(:registration, :has_required_data) }
        let(:registration_b) { create(:registration, :has_required_data) }

        before { registration_b.reg_identifier = registration_a.reg_identifier }

        it "is not valid" do
          expect(registration_b).not_to be_valid
        end
      end
    end

    describe "#renew_token" do
      context "when there is already one set" do
        let(:registration) { create(:registration, :has_required_data, renew_token: renew_token) }
        let(:renew_token) { "footoken" }

        it "returns the existing token" do
          expect(registration.renew_token).to eq(renew_token)
        end
      end

      context "when one has not been set" do
        context "when the registration can be renewed" do
          let(:expiry_check_service) { instance_double(ExpiryCheckService) }
          let(:registration) do
            reg = create(
              :registration,
              :has_required_data,
              :expires_soon,
              tier: "UPPER"
            )
            reg.metaData.status = "ACTIVE"
            reg
          end

          before do
            allow(ExpiryCheckService).to receive(:new).and_return(expiry_check_service)
            allow(expiry_check_service).to receive(:in_expiry_grace_window?).and_return(true)
          end

          it "returns a new token" do
            result = registration.renew_token

            expect(result).to be_present
            expect(result.length >= 20).to be_truthy
          end
        end

        context "when the registration cannot be renewed" do
          let(:registration) { create(:registration, :has_required_data) }

          it "returns nothing" do
            result = registration.renew_token

            expect(result).to be_nil
          end
        end
      end
    end

    describe "#already_renewed?" do
      let(:registration) { create(:registration, :has_required_data, :expires_soon) }

      context "when the registration has no past_registrations" do
        it "returns false" do
          expect(registration.past_registrations).to be_empty
          expect(registration).not_to be_already_renewed
        end
      end

      context "when the registration has past_registrations" do
        let(:past_registration) { PastRegistration.build_past_registration(registration) }

        context "when the past_registration has an expiry date more than 6 months ago" do
          before do
            past_registration.update(expires_on: 1.year.ago)
          end

          it "returns false" do
            expect(registration).not_to be_already_renewed
          end
        end

        context "when the past_registration has an expiry date less than 6 months old" do
          before do
            past_registration.update(expires_on: 1.month.ago)
          end

          context "when it is an edit" do
            before do
              past_registration.update(cause: "edit")
            end

            it "returns false" do
              expect(registration).not_to be_already_renewed
            end
          end

          context "when it is a renewal" do
            before do
              past_registration.update(cause: nil)
            end

            it "returns true" do
              expect(registration).to be_already_renewed
            end
          end
        end
      end
    end

    describe "#past_renewal_window?" do
      let(:registration) { build(:registration, :has_required_data, expires_on: expires_on) }

      context "when the registration has expired too long ago" do
        let(:expires_on) { Time.now.to_date - Rails.configuration.grace_window.days - 1 }

        it "returns true" do
          expect(registration).to be_past_renewal_window
        end
      end

      context "when the registration has not expired too long ago" do
        let(:expires_on) { Time.now.to_date }

        it "returns false" do
          expect(registration).not_to be_past_renewal_window
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
          expect(result).not_to include(revoked_registration)
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
          expect(result).not_to include(revoked)
        end
      end

      describe ".lower_tier_or_unexpired" do
        it "returns registrations which are lower tier or unexpired" do
          future_expire_date = create(:registration, :has_required_data, expires_on: 2.days.from_now)
          in_grace_window = create(:registration, :has_required_data, expires_on: 2.days.ago)
          lower_tier = create(:registration, :has_required_data, :lower_tier, expires_on: nil)

          result = described_class.lower_tier_or_unexpired

          expect(result).to include(future_expire_date)
          expect(result).to include(lower_tier)
          expect(result).not_to include(in_grace_window)
        end
      end

      describe ".expired_at_end_of_today" do
        it "returns registrations that have expired at the end of current day" do
          expired_registration = create(:registration, :has_required_data, expires_on: Time.now.beginning_of_day + 4.hours)
          active_registration = create(:registration, :has_required_data, expires_on: Time.now.end_of_day + 4.hours)

          result = described_class.expired_at_end_of_today

          expect(result).to include(expired_registration)
          expect(result).not_to include(active_registration)
        end
      end

      describe ".upper_tier" do
        it "returns upper tier registrations" do
          upper_tier_registration = create(:registration, :has_required_data, tier: "UPPER")
          lower_tier_registration = create(:registration, :has_required_data, tier: "LOWER")

          result = described_class.upper_tier

          expect(result).to include(upper_tier_registration)
          expect(result).not_to include(lower_tier_registration)
        end
      end

      describe ".not_cancelled" do
        it "returns objects that are not in an INACTIVE state" do
          cancelled_registration = create(:registration, :has_required_data, :cancelled)
          active_registration = create(:registration, :has_required_data)

          results = described_class.not_cancelled

          expect(results).to include(active_registration)
          expect(results).not_to include(cancelled_registration)
        end
      end

      describe ".communications_accepted" do
        # rubocop:disable RSpec/LetSetup
        let!(:registration_not_specified) { create(:registration, :has_required_data) }
        let!(:registration_opted_in) { create(:registration, :has_required_data, communications_opted_in: true) }
        let!(:registration_opted_out) { create(:registration, :has_required_data, communications_opted_in: false) }
        # rubocop:enable RSpec/LetSetup

        it do
          expect(described_class.communications_accepted)
            .to contain_exactly(registration_not_specified, registration_opted_in)
        end
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
          expect(registration).not_to be_valid
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
          expect(registration).not_to be_valid
        end
      end
    end

    describe "#address" do
      context "when a registration has one address" do
        let(:address) { build(:address, :registered, :has_required_data) }
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
        let(:address_a) { build(:address, :registered, :has_required_data) }
        let(:address_b) { build(:address, :contact, :has_required_data) }
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
          expect(registration).not_to be_valid
        end
      end

      context "when registration has an address which has a location" do
        let(:location) { build(:location) }
        let(:address) { build(:address, :registered, :has_required_data, location: location) }
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
            expect(registration).not_to be_valid
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
          expect(registration).not_to be_valid
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
            expect(registration).not_to be_valid
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

          it "can be cancelled" do
            expect(registration.metaData).to allow_event :cancel
            expect(registration.metaData).to transition_from(:PENDING).to(:INACTIVE).on_event(:cancel)
          end

          it "cannot be revoked" do
            expect(registration.metaData).not_to allow_event :revoke
          end

          it "cannot be renewed" do
            expect(registration.metaData).not_to allow_event :renew
          end

          it "cannot expire" do
            expect(registration.metaData).not_to allow_event :expire
          end

          it "cannot transition to 'revoked', 'renewed' or 'expired'" do
            expect(registration.metaData).not_to allow_transition_to(:REVOKED)
            expect(registration.metaData).not_to allow_transition_to(:renewed)
            expect(registration.metaData).not_to allow_transition_to(:EXPIRED)
          end
        end

        context "when a registration is activated" do
          let(:registration) { create(:registration, :has_required_data, :is_pending) }

          before { allow(Rails.configuration).to receive(:expires_after).and_return(3) }

          it "sets expires_on 3 years in the future" do
            expect(registration.expires_on).to be_nil

            registration.metaData.activate!

            # Use .to_i to ignore milliseconds when comparing time
            expect(registration.reload.expires_on.to_i)
              .to be_within(1).of(3.years.from_now.to_i)
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
            expect(registration.metaData).not_to allow_event :refuse
          end

          it "cannot be activated" do
            expect(registration.metaData).not_to allow_event :activate
          end

          it "cannot transition to 'pending' or 'refused'" do
            expect(registration.metaData).not_to allow_transition_to(:PENDING)
            expect(registration.metaData).not_to allow_transition_to(:REFUSED)
          end
        end

        context "when a registration is refused" do
          let(:registration) { build(:registration, :is_refused) }

          it "has 'refused' status" do
            expect(registration.metaData).to have_state(:REFUSED)
          end

          it "cannot transition to other states" do
            expect(registration.metaData).not_to allow_transition_to(:PENDING)
            expect(registration.metaData).not_to allow_transition_to(:ACTIVE)
            expect(registration.metaData).not_to allow_transition_to(:REFUSED)
            expect(registration.metaData).not_to allow_transition_to(:REVOKED)
          end
        end

        context "when a registration is revoked" do
          let(:registration) { build(:registration, :is_revoked) }

          it "has 'revoked' status" do
            expect(registration.metaData).to have_state(:REVOKED)
          end

          it "cannot transition to other states" do
            expect(registration.metaData).not_to allow_transition_to(:PENDING)
            expect(registration.metaData).not_to allow_transition_to(:ACTIVE)
            expect(registration.metaData).not_to allow_transition_to(:REFUSED)
            expect(registration.metaData).not_to allow_transition_to(:REVOKED)
          end
        end

        context "when a registration is expired" do
          let(:registration) { build(:registration, :has_required_data, :is_expired, expires_on: 1.month.ago) }

          it "has 'expired' status" do
            expect(registration.metaData).to have_state(:EXPIRED)
          end

          it "cannot be revoked" do
            expect(registration.metaData).not_to allow_event :revoke
          end

          it "cannot be refused" do
            expect(registration.metaData).not_to allow_event :refuse
          end

          it "cannot expire" do
            expect(registration.metaData).not_to allow_event :expire
          end

          it "cannot transition to 'pending', 'refused', 'revoked'" do
            expect(registration.metaData).not_to allow_transition_to(:PENDING)
            expect(registration.metaData).not_to allow_transition_to(:REFUSED)
            expect(registration.metaData).not_to allow_transition_to(:REVOKED)
          end
        end
      end
    end

    describe "search" do
      it_behaves_like "Search scopes",
                      record_class: described_class,
                      factory: :registration
    end

    describe "#renewal" do
      it "returns a transient renewal" do
        renewing_registration = create(:renewing_registration)
        registration = renewing_registration.registration

        expect(registration.renewal).to eq(renewing_registration)
      end
    end

    describe "#can_start_renewal?" do
      let(:registration) { build(:registration, :has_required_data) }
      let(:expiry_check_service) { instance_double(ExpiryCheckService) }

      before do
        allow(ExpiryCheckService).to receive(:new).and_return(expiry_check_service)
      end

      context "when the registration is lower tier" do
        before { registration.tier = "LOWER" }

        it "returns false" do
          expect(registration.can_start_renewal?).to be false
        end
      end

      context "when the registration is upper tier" do
        before { registration.tier = "UPPER" }

        context "when the registration has been revoked or refused" do
          before { registration.metaData.status = %w[REVOKED REFUSED].sample }

          it "returns false" do
            expect(registration.can_start_renewal?).to be false
          end
        end

        context "when the registration has not been revoked or refused" do
          before do
            registration.metaData.status = "ACTIVE"
            registration.expires_on = Time.current + 1.day
          end

          context "when the registration is in the grace window" do
            before { allow(expiry_check_service).to receive(:in_expiry_grace_window?).and_return(true) }

            it "returns true" do
              expect(registration.can_start_renewal?).to be true
            end
          end

          context "when the registration is not in the grace window" do
            before { allow(expiry_check_service).to receive(:in_expiry_grace_window?).and_return(false) }

            context "when the registration is past the expiry date" do
              before { allow(expiry_check_service).to receive(:expired?).and_return(true) }

              it "returns false" do
                expect(registration.can_start_renewal?).to be false
              end
            end

            context "when the registration is not past the expiry date" do
              before { allow(expiry_check_service).to receive(:expired?).and_return(false) }

              context "when the registration is in the renewal window" do
                before { allow(expiry_check_service).to receive(:in_renewal_window?).and_return(true) }

                it "returns true" do
                  expect(registration.can_start_renewal?).to be true
                end
              end

              context "when the result is not in the renewal window" do
                before { allow(expiry_check_service).to receive(:in_renewal_window?).and_return(false) }

                it "returns false" do
                  expect(registration.can_start_renewal?).to be false
                end
              end
            end
          end
        end
      end
    end

    describe "#original_registration_date" do
      let(:registration) { create(:registration, :has_required_data, metaData: { dateRegistered: 2.years.ago }) }

      describe "registration renewal" do
        let(:create_past_registration) { PastRegistration.build_past_registration(registration) }

        it "returns registration date of the very first registration" do
          old_registration = create_past_registration
          registration.metaData.update(dateRegistered: Date.today)
          expect(registration.reload.past_registrations.length).to eq(1)
          expect(registration.original_registration_date.to_date).to eq(old_registration.metaData.dateRegistered.to_date)
        end
      end

      describe "first and only registration" do
        it "returns registration date of the current registration" do
          expect(registration.reload.past_registrations.length).to eq(0)
          expect(registration.original_registration_date.to_date).to eq(registration.metaData.dateRegistered.to_date)
        end
      end
    end

    describe "#original_activation_date" do
      let(:registration) { create(:registration, :has_required_data, metaData: { dateActivated: 2.years.ago }) }

      describe "registration renewal" do
        let(:create_past_registration) { PastRegistration.build_past_registration(registration) }

        it "returns activation date of the very first registration" do
          old_registration = create_past_registration
          registration.metaData.update(dateActivated: Date.today)
          expect(registration.reload.past_registrations.length).to eq(1)
          expect(registration.original_activation_date.to_date).to eq(old_registration.metaData.dateActivated.to_date)
        end

        it "returns activation date of the next registration if the first one doesn't have activation date set" do
          old_registration = create_past_registration
          old_registration.metaData.update(dateActivated: nil)
          registration.metaData.update(dateActivated: Date.today)
          expect(registration.reload.past_registrations.length).to eq(1)
          expect(registration.original_activation_date.to_date).to eq(registration.metaData.dateActivated.to_date)
        end
      end

      describe "first and only registration" do
        it "returns activation date of the current registration" do
          expect(registration.reload.past_registrations.length).to eq(0)
          expect(registration.original_activation_date.to_date).to eq(registration.metaData.dateActivated.to_date)
        end
      end
    end

    describe "#increment_certificate_version" do
      let(:user) { create(:user) }

      context "when version is already present" do
        let(:meta_data) { build(:metaData, certificateVersion: 1, certificateVersionHistory: [{ foo: :bar }]) }
        let(:registration) { create(:registration, :has_required_data, metaData: meta_data) }

        it "increments verson number by 1" do
          registration.increment_certificate_version(user)
          expect(registration.metaData.certificate_version).to eq(2)
        end

        it "updates certificate_version_history" do
          registration.increment_certificate_version(user)
          expect(registration.metaData.certificate_version_history.length).to eq 2
          expect(registration.metaData.certificate_version_history.last[:version]).to eq(2)
          expect(registration.metaData.certificate_version_history.last[:generated_by]).to eq(user.email)
          expect(registration.metaData.certificate_version_history.last[:generated_at]).to be_present
        end
      end

      context "when version has not been set" do
        let(:meta_data) { build(:metaData) }
        let(:registration) { create(:registration, :has_required_data, metaData: meta_data) }

        # The version must default to 1 for historic registrations created before versioning go-live
        it "defaults to 1" do
          expect(meta_data.certificate_version).to eq 1
        end

        it "keeps the version at 1" do
          registration.increment_certificate_version(user)
          expect(registration.metaData.certificate_version).to eq(1)
        end

        it "updates certificate_version_history" do
          registration.increment_certificate_version(user)
          expect(registration.metaData.certificate_version_history.length).to eq 1
          expect(registration.metaData.certificate_version_history.last[:version]).to eq(1)
          expect(registration.metaData.certificate_version_history.last[:generated_by]).to eq(user.email)
          expect(registration.metaData.certificate_version_history.last[:generated_at]).to be_present
        end
      end
    end

    describe ".not_selected_for_email" do
      let(:registration) { create(:registration, :has_required_data) }
      let(:template_id) { "12345" }

      context "when the registration has not been selected for any emails" do
        it "returns the registration" do
          expect(described_class.not_selected_for_email(template_id)).to include(registration)
        end
      end

      context "when the registration has been selected for a different email" do
        before do
          registration.email_history << { email_type: "foo", template_id: "54321", time: Time.zone.now }
          registration.save!
        end

        it "returns the registration" do
          expect(described_class.not_selected_for_email(template_id)).to include(registration)
        end
      end

      context "when the registration has been selected for this email" do
        before do
          registration.email_history << { email_type: "foo", template_id: template_id, time: Time.zone.now }
          registration.save!
        end

        it "does not return the registration" do
          expect(described_class.not_selected_for_email(template_id)).not_to include(registration)
        end
      end
    end

    describe "status" do
      it_behaves_like "Can check registration status",
                      factory: :registration
    end

    describe "registration attributes" do
      it_behaves_like "Can have registration attributes",
                      factory: :registration
    end

    describe "entity_display names" do
      it_behaves_like "Can present entity display name",
                      factory: :registration
    end

    describe "conviction scopes" do
      it_behaves_like "Can filter conviction status"
    end
  end
end
