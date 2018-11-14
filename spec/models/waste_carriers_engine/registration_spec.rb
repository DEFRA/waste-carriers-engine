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

      context "when a registration is created" do
        let(:registration) { create(:registration, :has_required_data) }

        it "should have a unique reg_identifier" do
          expect(Registration.where(reg_identifier: registration.reg_identifier).count).to eq(1)
        end

        context "when another registration is created after that" do
          let(:registration_b) { create(:registration, :has_required_data) }

          it "should have a sequential reg_identifier" do
            reg_identifier_a = registration.reg_identifier
            reg_identifier_b = registration_b.reg_identifier

            reg_identifier_a.slice!("CBDU")
            reg_identifier_b.slice!("CBDU")

            expect(reg_identifier_b.to_i - reg_identifier_a.to_i).to eq(1)
          end
        end
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
          let(:registration) { build(:registration, :is_pending) }

          it "sets expires_on 3 years in the future" do
            expect(registration.expires_on).to be_nil
            registration.metaData.activate
            # Use .to_i to ignore milliseconds when comparing time
            expect(registration.expires_on.to_i).to eq(3.years.from_now.to_i)
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

          context "when the registration expiration date is more than 6 months away" do
            let(:registration) { build(:registration, :is_active, expires_on: 1.year.from_now) }

            it "cannot be renewed" do
              expect(registration.metaData).to_not allow_event :renew
            end
          end

          context "when the registration expiration date is less than 6 months away" do
            let(:registration) { build(:registration, :is_active, expires_on: 1.month.from_now) }

            it "can be renewed" do
              expect(registration.metaData).to allow_event :renew
              expect(registration.metaData).to transition_from(:ACTIVE).to(:ACTIVE).on_event(:renew)
            end
          end

          context "when the registration expiration date was three days ago, it cannot be renewed today" do
            before { allow(Rails.configuration).to receive(:grace_window).and_return(3) }

            let(:registration) { build(:registration, :is_active, expires_on: Date.today) }

            it "cannot be renewed in 3 days time" do
              Timecop.freeze(registration.expires_on + 3.days) do
                expect(registration.metaData).to_not allow_event :renew
              end
            end
          end

          context "when the registration was created in BST and expires in GMT" do
            before { allow(Rails.configuration).to receive(:grace_window).and_return(3) }

            # Registration is made during British Summer Time (BST)
            # UK local time is 00:30 on 28 March 2017
            # UTC time is 23:30 on 27 March 2017
            # Registration should expire on 28 March 2020
            let!(:registration) do
              registration = build(:registration, :has_required_data)
              registration.metaData.status = "EXPIRED"
              registration.metaData.date_registered = Time.find_zone("London").local(2017, 3, 28, 0, 30)
              registration.expires_on = registration.metaData.date_registered + 3.years
              registration
            end

            it "does not expire a day early due to the time difference" do
              # Skip ahead to the end of the last day the reg should be active
              Timecop.freeze(Time.find_zone("London").local(2020, 3, 27, 23, 59)) do
                # GMT is now in effect (not BST)
                # UK local time & UTC are both 23:59 on 27 March 2020
                expect(registration.metaData).to allow_event :renew
              end
            end

            it "cannot be renewed when it reaches the expiry date plus 'grace window' in the UK" do
              # Skip ahead to the start of the day a reg should expire, plus the
              # grace window
              Timecop.freeze(Time.find_zone("London").local(2020, 3, 31, 0, 1)) do
                # GMT is now in effect (not BST)
                # UK local time & UTC are both 00:01 on 28 March 2020
                expect(registration.metaData).to_not allow_event :renew
              end
            end
          end

          context "when the registration was created in GMT and expires in BST" do
            before { allow(Rails.configuration).to receive(:grace_window).and_return(3) }

            # Registration is made in during Greenwich Mean Time (GMT)
            # UK local time & UTC are both 23:30 on 27 October 2015
            # Registration should expire on 27 October 2018
            let!(:registration) do
              registration = build(:registration, :has_required_data)
              registration.metaData.status = "EXPIRED"
              registration.metaData.date_registered = Time.find_zone("London").local(2015, 10, 27, 23, 30)
              registration.expires_on = registration.metaData.date_registered + 3.years
              registration
            end

            it "does not expire a day early due to the time difference" do
              # Skip ahead to the end of the last day the reg should be active
              Timecop.freeze(Time.find_zone("London").local(2018, 10, 26, 23, 59)) do
                # BST is now in effect (not GMT)
                # UK local time is 23:59 on 26 October 2018
                # UTC time is 22:59 on 26 October 2018
                expect(registration.metaData).to allow_event :renew
              end
            end

            it "cannot be renewed when it reaches the expiry date plus 'grace window' in the UK" do
              # Skip ahead to the start of the day a reg should expire, plus the
              # grace window
              Timecop.freeze(Time.find_zone("London").local(2018, 10, 30, 0, 1)) do
                # BST is now in effect (not GMT)
                # UK local time is 00:01 on 27 October 2018
                # UTC time is 23:01 on 26 October 2018
                expect(registration.metaData).to_not allow_event :renew
              end
            end
          end

          context "when a registration is renewed" do
            let(:registration) { build(:registration, :is_active, expires_on: 1.month.from_now) }

            it "extends expires_on by 3 years" do
              old_expiry_date = registration.expires_on
              registration.metaData.renew
              new_expiry_date = registration.expires_on

              # Use .to_i to ignore milliseconds when comparing time
              expect(new_expiry_date.to_i).to eq((old_expiry_date + 3.years).to_i)
            end

            it "updates the registration's date_registered" do
              Timecop.freeze do
                registration.metaData.renew
                expect(registration.metaData.date_registered).to eq(Time.current)
              end
            end

            it "updates the registration's date_activated" do
              Timecop.freeze do
                registration.metaData.renew
                expect(registration.metaData.date_activated).to eq(Time.current)
              end
            end
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

          context "and when dealing with the 'grace window'" do
            before { allow(Rails.configuration).to receive(:grace_window).and_return(3) }

            let(:registration) { build(:registration, :has_required_data, :is_expired, expires_on: Date.today) }

            context "when outside it" do
              it "cannot be renewed" do
                Timecop.freeze(registration.expires_on + Rails.configuration.grace_window) do
                  expect(registration.metaData).to_not allow_event :renew
                end
              end
            end

            context "when inside it" do
              it "can be renewed" do
                Timecop.freeze((registration.expires_on + Rails.configuration.grace_window) - 1.day) do
                  expect(registration.metaData).to allow_event :renew
                end
              end
            end

            context "when there is no 'grace window'" do
              before { allow(Rails.configuration).to receive(:grace_window).and_return(0) }

              it "cannot be renewed" do
                Timecop.freeze(registration.expires_on + Rails.configuration.grace_window) do
                  expect(registration.metaData).to_not allow_event :renew
                end
              end
            end
          end

          context "and a transient registration exists" do
            let(:transient_registration) { build(:transient_registration, :has_required_data) }

            before do
              # These checks require the registration to be persisted
              registration.save!
              transient_registration.update_attributes(reg_identifier: registration.reg_identifier)
            end

            context "and when the transient_registration has a confirmed declaration" do
              it "can be renewed" do
                transient_registration.update_attributes(workflow_state: "cards_form", declaration: 1)
                expect(registration.metaData).to allow_event :renew
              end
            end

            context "and when the transient_registration is in a submitted state" do
              it "can be renewed" do
                transient_registration.update_attributes(workflow_state: "renewal_received_form")
                expect(registration.metaData).to allow_event :renew
              end
            end

            it "cannot be renewed if not declared or in a submitted state" do
              expect(registration.metaData).to_not allow_event :renew
            end
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
  end
end
