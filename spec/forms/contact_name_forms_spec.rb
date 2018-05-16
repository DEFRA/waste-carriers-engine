require "rails_helper"

RSpec.describe ContactNameForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:contact_name_form) { build(:contact_name_form, :has_required_data) }
      let(:valid_params) do
        {
          reg_identifier: contact_name_form.reg_identifier,
          first_name: contact_name_form.first_name,
          last_name: contact_name_form.last_name
        }
      end

      it "should submit" do
        expect(contact_name_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:contact_name_form) { build(:contact_name_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(contact_name_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  include_examples "validate person name", form = :contact_name_form, field = :first_name
  include_examples "validate person name", form = :contact_name_form, field = :last_name
end
