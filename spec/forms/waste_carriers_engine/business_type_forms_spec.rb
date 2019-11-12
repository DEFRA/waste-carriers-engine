# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe BusinessTypeForm, type: :model do
    let(:transient_registration) { double(:transient_registration) }
    subject(:business_type_form) { described_class.new(transient_registration) }

    describe "#initialize" do
      it "assigns an instance variable called transient_registration" do
        expect(business_type_form.instance_variable_get(:@transient_registration)).to eq(transient_registration)
      end
    end

    context "validations" do
      let(:validators) { business_type_form._validators }

      it "validates the business type using the BusinessTypeValidator class" do
        expect(validators.keys).to include(:business_type)

        validator = validators[:business_type].first

        expect(validator.class)
          .to eq(DefraRuby::Validators::BusinessTypeValidator)
        expect(validator.options).to include(allow_overseas: true)
      end

      # TODO: These validations are defined in the BaseForm
      it "validates the registration identifier using the RegIdentifier class" do
        expect(validators.keys).to include(:reg_identifier)
        expect(validators[:reg_identifier].first.class)
          .to eq(WasteCarriersEngine::RegIdentifierValidator)
      end

      it "validates the transient_registration" do
        skip "TODO: Cannot get `validate` defined validators in list of _validators"
      end
    end

    context "delegates" do
      let(:business_type) { double(:business_type) }
      let(:transient_registration) { double(:transient_registration, business_type: business_type) }

      describe "#business_type" do
        it "delegates the business_type to the transient_registration" do
          expect(business_type_form.business_type).to eq(business_type)
        end
      end
    end

    describe "#submit" do
      let(:params) { {} }

      before do
        expect(business_type_form).to receive(:valid?).and_return(is_form_valid)
        expect(transient_registration).to receive(:assign_attributes).with(params)
      end

      context "when the form is valid" do
        let(:is_form_valid) { true }

        before do
          # TODO: if we are stubbing the main form `validate`, the transient_registration `validate` never gets called
          # expect(transient_registration).to receive(:valid?).and_return(is_transient_registration_valid)
        end

        context "when the transient_registration is valid" do
          let(:is_transient_registration_valid) { true }

          it "should submit" do
            expect(transient_registration).to receive(:save!).and_return(true)
            expect(business_type_form.submit(params)).to eq(true)
          end
        end

        context "when the transient_registration is not valid" do
          let(:is_transient_registration_valid) { false }

          it "should not submit" do
            skip "TODO: only integration possible - To implement in `BaseForm` specific test"

            error = [0, "my message"]
            errors = [error]
            error_base = double(:error_base)

            expect(transient_registration).to receive(:errors).and_return(errors)
            expect(error).to receive(:[]).with(:base).and_return(error_base)
            expect(error_base).to receive(:<<).with("my message")

            expect(business_type_form.submit(params)).to eq(false)
          end
        end
      end

      context "when the form is not valid" do
        let(:is_form_valid) { false }

        it "should not submit" do
          expect(business_type_form.submit(params)).to eq(false)
        end
      end
    end
  end
end
