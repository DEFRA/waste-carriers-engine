# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe DeclarationForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:declaration_form) { build(:declaration_form, :has_required_data) }
        let(:valid_params) do
          {
            token: declaration_form.token,
            declaration: 1
          }
        end

        it "should submit" do
          expect(declaration_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:declaration_form) { build(:declaration_form, :has_required_data) }
        let(:invalid_params) do
          {
            token: "foo",
            declaration: "foo"
          }
        end

        it "should not submit" do
          expect(declaration_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    context "when a valid transient registration exists" do
      let(:declaration_form) { build(:declaration_form, :has_required_data) }

      describe "#declaration" do
        context "when a declaration meets the requirements" do
          it "is valid" do
            expect(declaration_form).to be_valid
          end
        end

        context "when a declaration is blank" do
          before(:each) do
            declaration_form.transient_registration.declaration = ""
          end

          it "is not valid" do
            expect(declaration_form).to_not be_valid
          end
        end

        context "when a declaration is 0" do
          before(:each) do
            declaration_form.transient_registration.declaration = 0
          end

          it "is not valid" do
            expect(declaration_form).to_not be_valid
          end
        end
      end
    end
  end
end
