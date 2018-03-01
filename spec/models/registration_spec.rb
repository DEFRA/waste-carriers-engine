require "rails_helper"

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

  describe "#convictionSearchResult" do
    context "when a registration has a convictionSearchResult" do
      let(:conviction_search_result) { build(:convictionSearchResult) }
      let(:registration) do
        build(:registration,
              :has_required_data,
              convictionSearchResult: conviction_search_result)
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

  describe "#financeDetails" do
    context "when a registration has a financeDetails" do
      let(:finance_details) { build(:financeDetails, :has_required_data) }
      let(:registration) do
        build(:registration,
              :has_required_data,
              financeDetails: finance_details)
      end

      it "is valid" do
        expect(registration).to be_valid
      end
    end

    describe "#balance" do
      context "when a registration has a financeDetails which has no balance" do
        let(:finance_details) { build(:financeDetails, balance: nil) }
        let(:registration) do
          build(:registration,
                :has_required_data,
                financeDetails: finance_details)
        end

        it "is not valid" do
          expect(registration).to_not be_valid
        end
      end
    end

    describe "#orders" do
      context "when a registration has a financeDetails which has one order" do
        let(:order) { build(:order) }
        let(:finance_details) { build(:financeDetails, :has_required_data, orders: [order]) }
        let(:registration) do
          build(:registration,
                :has_required_data,
                financeDetails: finance_details)
        end

        it "is valid" do
          expect(registration).to be_valid
        end
      end

      context "when a registration has a financeDetails which has multiple orders" do
        let(:order_a) { build(:order) }
        let(:order_b) { build(:order) }
        let(:finance_details) { build(:financeDetails, :has_required_data, orders: [order_a, order_b]) }
        let(:registration) do
          build(:registration,
                :has_required_data,
                financeDetails: finance_details)
        end

        it "is valid" do
          expect(registration).to be_valid
        end
      end

      describe "#orderItems" do
        context "when a registration has a financeDetails which has an order which has an orderItem" do
          let(:order_item) { build(:orderItem) }
          let(:order) { build(:order, orderItems: [order_item]) }
          let(:finance_details) { build(:financeDetails, :has_required_data, orders: [order]) }
          let(:registration) do
            build(:registration,
                  :has_required_data,
                  financeDetails: finance_details)
          end

          it "is valid" do
            expect(registration).to be_valid
          end
        end

        context "when a registration has a financeDetails which has an order which has multiple orderItems" do
          let(:order_item_a) { build(:orderItem) }
          let(:order_item_b) { build(:orderItem) }
          let(:order) { build(:order, orderItems: [order_item_a, order_item_b]) }
          let(:finance_details) { build(:financeDetails, :has_required_data, orders: [order]) }
          let(:registration) do
            build(:registration,
                  :has_required_data,
                  financeDetails: finance_details)
          end

          it "is valid" do
            expect(registration).to be_valid
          end
        end
      end
    end

    describe "#payments" do
      context "when a registration has a financeDetails which has one payment" do
        let(:payment) { build(:payment) }
        let(:finance_details) { build(:financeDetails, :has_required_data, payments: [payment]) }
        let(:registration) do
          build(:registration,
                :has_required_data,
                financeDetails: finance_details)
        end

        it "is valid" do
          expect(registration).to be_valid
        end
      end

      context "when a registration has a financeDetails which has multiple payments" do
        let(:payment_a) { build(:payment) }
        let(:payment_b) { build(:payment) }
        let(:finance_details) { build(:financeDetails, :has_required_data, payments: [payment_a, payment_b]) }
        let(:registration) do
          build(:registration,
                :has_required_data,
                financeDetails: finance_details)
        end

        it "is valid" do
          expect(registration).to be_valid
        end
      end
    end
  end

  describe "#keyPeople" do
    context "when a registration has one key person" do
      let(:key_person) { build(:key_person, :has_required_data) }
      let(:registration) do
        build(:registration,
              :has_required_data,
              keyPeople: [key_person])
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
              keyPeople: [key_person_a,
                          key_person_b])
      end

      it "is valid" do
        expect(registration).to be_valid
      end
    end

    describe "#convictionSearchResult" do
      context "when a registration's key person has a convictionSearchResult" do
        let(:conviction_search_result) { build(:convictionSearchResult) }
        let(:key_person) { build(:key_person, :has_required_data, convictionSearchResult: conviction_search_result) }
        let(:registration) do
          build(:registration,
                :has_required_data,
                keyPeople: [key_person])
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
          expect(registration.metaData).to have_state(:pending)
        end

        it "is not valid without a status" do
          registration.metaData.status = nil
          expect(registration).to_not be_valid
        end
      end

      context "when a registration is pending" do
        let(:registration) { build(:registration, :is_pending) }

        it "has 'pending' status" do
          expect(registration.metaData).to have_state(:pending)
        end

        it "can be activated" do
          expect(registration.metaData).to allow_event :activate
          expect(registration.metaData).to transition_from(:pending).to(:active).on_event(:activate)
        end

        it "can be refused" do
          expect(registration.metaData).to allow_event :refuse
          expect(registration.metaData).to transition_from(:pending).to(:refused).on_event(:refuse)
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
          expect(registration.metaData).to_not allow_transition_to(:revoked)
          expect(registration.metaData).to_not allow_transition_to(:renewed)
          expect(registration.metaData).to_not allow_transition_to(:expired)
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
          expect(registration.metaData).to have_state(:active)
        end

        it "can be revoked" do
          expect(registration.metaData).to allow_event :revoke
          expect(registration.metaData).to transition_from(:active).to(:revoked).on_event(:revoke)
        end

        it "can expire" do
          expect(registration.metaData).to allow_event :expire
          expect(registration.metaData).to transition_from(:active).to(:expired).on_event(:expire)
        end

        it "cannot be refused" do
          expect(registration.metaData).to_not allow_event :refuse
        end

        it "cannot be activated" do
          expect(registration.metaData).to_not allow_event :activate
        end

        it "cannot transition to 'pending' or 'refused'" do
          expect(registration.metaData).to_not allow_transition_to(:pending)
          expect(registration.metaData).to_not allow_transition_to(:refused)
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
            expect(registration.metaData).to transition_from(:active).to(:active).on_event(:renew)
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
        end
      end

      context "when a registration is refused" do
        let(:registration) { build(:registration, :is_refused) }

        it "has 'refused' status" do
          expect(registration.metaData).to have_state(:refused)
        end

        it "cannot transition to other states" do
          expect(registration.metaData).to_not allow_transition_to(:pending)
          expect(registration.metaData).to_not allow_transition_to(:active)
          expect(registration.metaData).to_not allow_transition_to(:refused)
          expect(registration.metaData).to_not allow_transition_to(:revoked)
        end
      end

      context "when a registration is revoked" do
        let(:registration) { build(:registration, :is_revoked) }

        it "has 'revoked' status" do
          expect(registration.metaData).to have_state(:revoked)
        end

        it "cannot transition to other states" do
          expect(registration.metaData).to_not allow_transition_to(:pending)
          expect(registration.metaData).to_not allow_transition_to(:active)
          expect(registration.metaData).to_not allow_transition_to(:refused)
          expect(registration.metaData).to_not allow_transition_to(:revoked)
        end
      end

      context "when a registration is expired" do
        let(:registration) { build(:registration, :is_expired, expires_on: 1.month.ago) }

        it "has 'expired' status" do
          expect(registration.metaData).to have_state(:expired)
        end

        # Users are able to renew expired registration
        # Probably with some limits... TODO find out about that!
        it "can renew" do
          expect(registration.metaData).to allow_event :renew
          expect(registration.metaData).to transition_from(:expired).to(:active).on_event(:renew)
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
          expect(registration.metaData).to_not allow_transition_to(:pending)
          expect(registration.metaData).to_not allow_transition_to(:refused)
          expect(registration.metaData).to_not allow_transition_to(:revoked)
        end
      end
    end
  end
end
