# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditRegistration, type: :model do
    subject(:edit_registration) { build(:edit_registration) }

    it_should_behave_like "Can check if registration type changed"

    context "with default status" do
      context "when an EditRegistration is created" do
        it "has the state of :edit_form" do
          expect(edit_registration).to have_state(:edit_form)
        end
      end
    end

    context "with validations" do
      describe "reg_identifier" do
        context "when an EditRegistration is created" do
          it "is not valid if the reg_identifier is in the wrong format" do
            edit_registration.reg_identifier = "foo"
            expect(edit_registration).not_to be_valid
          end

          it "is not valid if no matching registration exists" do
            edit_registration.reg_identifier = "CBDU999999"
            expect(edit_registration).not_to be_valid
          end
        end
      end
    end

    describe "#initialize" do
      context "when it is initialized with a registration" do
        let(:registration) { create(:registration, :has_required_data) }
        let(:edit_registration) { described_class.new(reg_identifier: registration.reg_identifier) }

        copyable_properties = Registration.attribute_names - %w[_id
                                                                accountEmail
                                                                addresses
                                                                expires_on
                                                                key_people
                                                                financeDetails
                                                                conviction_search_result
                                                                conviction_sign_offs
                                                                declaration
                                                                past_registrations
                                                                copy_cards]

        copyable_properties.each do |property|
          it "copies #{property} from the registration" do
            expect(edit_registration[property]).to eq(registration[property])
          end
        end

        it "copies the addresses from the registration" do
          registration.addresses.each_with_index do |address, index|
            copyable_attributes = address.attributes.except("_id")
            expect(edit_registration.addresses[index].attributes).to include(copyable_attributes)
          end
        end

        it "copies the key_people from the registration" do
          registration.key_people.each_with_index do |person, index|
            copyable_attributes = person.attributes.except("_id",
                                                           "conviction_search_result")
            expect(edit_registration.key_people[index].attributes).to include(copyable_attributes)
          end
        end
      end
    end

    describe "#prepare_for_payment" do
      it "runs the EditFinanceDetailsBuilderService with the correct params" do
        mode = "OFFLINE"
        user = double(:user)

        expect(BuildEditFinanceDetailsService).to receive(:run).with(
          user: user,
          transient_registration: subject,
          payment_method: mode
        )

        subject.prepare_for_payment(mode, user)
      end
    end

    describe "#location_changed_from_overseas?" do
      context "when the registration is has an overseas location" do
        before { subject.registration.location = "overseas" }

        context "when the edit_registration has a UK location" do
          before { subject.location = "england" }

          it "returns true" do
            expect(subject.location_changed_from_overseas?).to be_truthy
          end
        end

        context "when the edit_registration does not have a UK location" do
          before { subject.location = "overseas" }

          it "returns false" do
            expect(subject.location_changed_from_overseas?).to be_falsey
          end
        end
      end

      context "when the registration is has an overseas business type" do
        before { subject.registration.business_type = "overseas" }

        context "when the edit_registration has a UK location" do
          before { subject.location = "england" }

          it "returns true" do
            expect(subject.location_changed_from_overseas?).to be_truthy
          end
        end

        context "when the edit_registration does not have a UK location" do
          before { subject.location = "overseas" }

          it "returns false" do
            expect(subject.location_changed_from_overseas?).to be_falsey
          end
        end
      end

      context "when the registration is not overseas" do
        before { subject.registration.location = "england" }

        it "returns false" do
          expect(subject.location_changed_from_overseas?).to be_falsey
        end
      end
    end
  end
end
