# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe BaseForm, type: :model do
    describe "#submit" do
      let(:base_form) { build(:base_form, :has_required_data) }

      it "should strip excess whitespace from attributes" do
        attributes = { company_name: " test " }

        base_form.submit(attributes, base_form.reg_identifier)
        expect(base_form.transient_registration.company_name).to eq("test")
      end

      it "should strip excess whitespace from attributes within an array" do
        attributes = { key_people: [build(:key_person, :main, first_name: " test ")] }

        base_form.submit(attributes, base_form.reg_identifier)
        expect(base_form.transient_registration.main_people.first.first_name).to eq("test")
      end

      it "should strip excess whitespace from attributes within a hash" do
        attributes = { metaData: { revoked_reason: " test " } }

        base_form.submit(attributes, base_form.reg_identifier)
        expect(base_form.transient_registration.metaData.revoked_reason).to eq("test")
      end
    end

    describe "#reg_identifier" do
      let(:base_form) { build(:base_form, :has_required_data) }

      context "when the reg_identifier meets the requirements" do
        it "is valid" do
          expect(base_form).to be_valid
        end
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          base_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(base_form).to_not be_valid
        end
      end

      context "when a reg_identifier is in the wrong format" do
        before(:each) do
          base_form.reg_identifier = "foo"
        end

        it "is not valid" do
          expect(base_form).to_not be_valid
        end
      end
    end

    describe "#transient_registration" do
      context "when the transient registration is invalid" do
        let(:transient_registration) do
          build(:transient_registration,
                workflow_state: "business_type")
        end
        # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
        let(:form) { BusinessTypeForm.new(transient_registration) }

        before(:each) do
          # Make reg_identifier valid for the form, but not the transient object
          form.reg_identifier = transient_registration.reg_identifier
          transient_registration.reg_identifier = "foo"
        end

        it "is not valid" do
          expect(form).to_not be_valid
        end

        it "inherits the errors from the transient_registration" do
          form.valid?
          expect(form.errors[:base]).to include(I18n.t("activemodel.errors.models.waste_carriers_engine/transient_registration.attributes.reg_identifier.invalid_format"))
        end
      end
    end
  end
end
