require "rails_helper"

RSpec.describe BaseForm, type: :model do
  describe "#submit" do
    let(:base_form) { build(:base_form, :has_required_data) }

    it "should strip excess whitespace from attributes" do
      attributes = { company_name: " test " }

      base_form.submit(attributes, base_form.reg_identifier)
      expect(base_form.transient_registration.company_name).to eq("test")
    end

    it "should strip excess whitespace from attributes within an array" do
      attributes = { keyPeople: [build(:key_person, :main, first_name: " test ")] }

      base_form.submit(attributes, base_form.reg_identifier)
      expect(base_form.transient_registration.main_people.first.first_name).to eq("test")
    end

    it "should strip excess whitespace from attributes within a hash" do
      attributes = { metaData: { revoked_reason: " test " } }

      base_form.submit(attributes, base_form.reg_identifier)
      expect(base_form.transient_registration.metaData.revoked_reason).to eq("test")
    end
  end
end
