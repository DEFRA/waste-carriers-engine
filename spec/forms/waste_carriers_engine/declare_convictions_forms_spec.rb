# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe DeclareConvictionsForm do
    describe "#submit" do
      context "when the form is valid" do
        let(:declare_convictions_form) { build(:declare_convictions_form, :has_required_data) }
        let(:valid_params) do
          {
            token: declare_convictions_form.token,
            declared_convictions: declare_convictions_form.declared_convictions
          }
        end

        it "submits" do
          expect(declare_convictions_form.submit(valid_params)).to be true
        end
      end

      context "when the form is not valid" do
        let(:declare_convictions_form) { build(:declare_convictions_form, :has_required_data) }
        let(:invalid_params) do
          {
            token: declare_convictions_form.token,
            declared_convictions: "foo"
          }
        end

        it "does not submit" do
          expect(declare_convictions_form.submit(invalid_params)).to be false
        end
      end
    end

    it_behaves_like "validate yes no", :declare_convictions_form, :declared_convictions
  end
end
