# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe BaseForm, type: :model do
    describe "#submit" do
      let(:base_form) { build(:base_form, :has_required_data) }

      it "should strip excess whitespace from attributes" do
        attributes = { company_name: " test " }

        base_form.submit(attributes)
        expect(base_form.transient_registration.company_name).to eq("test")
      end

      it "should strip excess whitespace from attributes within an array" do
        attributes = { key_people: [build(:key_person, :main, first_name: " test ")] }

        base_form.submit(attributes)
        expect(base_form.transient_registration.main_people.first.first_name).to eq("test")
      end

      it "should strip excess whitespace from attributes within a hash" do
        attributes = { metaData: { revoked_reason: " test " } }

        base_form.submit(attributes)
        expect(base_form.transient_registration.metaData.revoked_reason).to eq("test")
      end
    end

    describe "#token" do
      let(:base_form) { build(:base_form, :has_required_data) }

      context "when a token is blank" do
        before do
          base_form.transient_registration.token = nil
        end

        it "is not valid" do
          expect(base_form).to_not be_valid
        end
      end
    end

    describe "#transient_registration" do
      context "when the transient registration is invalid" do
        let(:transient_registration) do
          build(:renewing_registration,
                workflow_state: "business_type")
        end
        # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
        let(:form) { BusinessTypeForm.new(transient_registration) }

        before do
          # Make reg_identifier invalid for the transient object
          transient_registration.reg_identifier = "foo"
        end

        it "is not valid" do
          expect(form).to_not be_valid
        end

        it "inherits the errors from the transient_registration" do
          form.valid?
          expect(form.errors[:base]).to include(I18n.t("activemodel.errors.models.waste_carriers_engine/renewing_registration.attributes.reg_identifier.invalid_format"))
        end
      end
    end
  end
end
