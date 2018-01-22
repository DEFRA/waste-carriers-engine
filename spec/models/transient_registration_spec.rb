require "rails_helper"

RSpec.describe TransientRegistration, type: :model do
  describe "#reg_identifier" do
    context "when a TransientRegistration is created" do
      let(:transient_registration) do
        build(:transient_registration,
              :has_required_data)
      end

      it "is not valid if the reg_identifier is in the wrong format" do
        transient_registration.reg_identifier = "foo"
        expect(transient_registration).to_not be_valid
      end

      it "is not valid if no matching registration exists" do
        transient_registration.reg_identifier = "CBDU999999"
        expect(transient_registration).to_not be_valid
      end

      it "is not valid if the reg_identifier is already in use" do
        existing_transient_registration = create(:transient_registration, :has_required_data)
        transient_registration.reg_identifier = existing_transient_registration.reg_identifier
        expect(transient_registration).to_not be_valid
      end
    end
  end

  describe "#workflow_state" do
    context "when a TransientRegistration is created" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data)
      end

      it "has the state :renewal_start_form" do
        expect(transient_registration).to have_state(:renewal_start_form)
      end
    end
  end

  describe "registration_type_changed?" do
    context "when a TransientRegistration is created" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data)
      end

      it "should return false" do
        expect(transient_registration.registration_type_changed?).to eq(false)
      end

      context "when the registration_type is updated" do
        before(:each) do
          transient_registration.registration_type = "broker_dealer"
        end

        it "should return true" do
          expect(transient_registration.registration_type_changed?).to eq(true)
        end
      end
    end
  end
end
