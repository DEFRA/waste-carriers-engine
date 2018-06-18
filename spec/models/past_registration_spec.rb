require "rails_helper"

RSpec.describe PastRegistration, type: :model do
  let(:registration) { build(:registration, :has_required_data, :expires_soon) }

  describe "build_past_registration" do
    let(:past_registration) { PastRegistration.build_past_registration(registration) }

    it "belongs to the registration" do
      expect(past_registration.registration).to eq(registration)
    end

    it "copies attributes from the registration" do
      expect(past_registration.company_name).to eq(registration.company_name)
    end

    it "copies nested objects from the registration" do
      expect(past_registration.registered_address).to eq(registration.registered_address)
    end
  end
end
