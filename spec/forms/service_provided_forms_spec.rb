require "rails_helper"

RSpec.describe ServiceProvidedForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:service_provided_form) { build(:service_provided_form, :has_required_data) }
      let(:valid_params) {
        {
          reg_identifier: service_provided_form.reg_identifier,
          is_main_service: service_provided_form.is_main_service
        }
      }

      it "should submit" do
        expect(service_provided_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:service_provided_form) { build(:service_provided_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(service_provided_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  context "when a valid transient registration exists" do
    let(:service_provided_form) { build(:service_provided_form, :has_required_data) }

    describe "#is_main_service" do
      context "when is_main_service is true" do
        before(:each) do
          service_provided_form.is_main_service = true
        end

        it "is valid" do
          expect(service_provided_form).to be_valid
        end
      end

      context "when is_main_service is false" do
        before(:each) do
          service_provided_form.is_main_service = false
        end

        it "is valid" do
          expect(service_provided_form).to be_valid
        end
      end

      context "when is_main_service is a non-boolean value" do
        before(:each) do
          service_provided_form.is_main_service = "foo"
        end

        it "is not valid" do
          expect(service_provided_form).to_not be_valid
        end
      end

      context "when is_main_service is nil" do
        before(:each) do
          service_provided_form.is_main_service = nil
        end

        it "is not valid" do
          expect(service_provided_form).to_not be_valid
        end
      end
    end
  end
end
