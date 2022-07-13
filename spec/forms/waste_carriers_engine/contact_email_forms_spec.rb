# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ContactEmailForm, type: :model do

    describe "#submit" do
      let(:contact_email_form) { build(:contact_email_form, :has_required_data) }

      let(:params) do
        {
          token: contact_email_form.token,
          contact_email: contact_email,
          confirmed_email: contact_email,
          no_contact_email: defined?(no_contact_email) ? no_contact_email : nil
        }
      end

      shared_examples "should submit" do
        it "submits the form successfully" do
          expect(contact_email_form.submit(ActionController::Parameters.new(params))).to eq(true)
        end
      end

      shared_examples "should not submit" do
        it "does not submit the form successfully" do
          expect(contact_email_form.submit(ActionController::Parameters.new(params))).to eq(false)
        end
      end

      context "when the form is valid" do
        context "when running in the front office" do
          before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(false) }

          context "with an email address" do
            let(:contact_email) { contact_email_form.contact_email }

            it_behaves_like "should submit"
          end
        end

        context "when running in the back office" do
          before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(true) }

          context "with an email address" do
            let(:contact_email) { contact_email_form.contact_email }

            it_behaves_like "should submit"
          end

          context "without an email address" do
            let(:contact_email) { nil }
            let(:no_contact_email) { "1" }

            it_behaves_like "should submit"
          end
        end
      end

      context "when the form is not valid" do
        context "when running in the front office" do
          before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(false) }

          context "with no parameters" do
            let(:params) { {} }

            it_behaves_like "should not submit"
          end
        end

        context "when running in the back office" do
          before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(true) }

          context "without an email address and with the no-email-address option not selected" do
            let(:contact_email) { nil }
            let(:no_contact_email) { "0" }

            it_behaves_like "should not submit"
          end

          context "with an email address and with the no-email-address option selected" do
            let(:contact_email) { contact_email_form.contact_email }
            let(:no_contact_email) { "1" }

            it_behaves_like "should not submit"
          end
        end
      end
    end

    describe "validate email" do
      before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(true) }

      it "validates the contact_email field using the ContactEmailValidator class" do
        validators = build(:contact_email_form, :has_required_data)._validators
        expect(validators.keys).to include(:contact_email)
        expect(validators[:contact_email].first.class).to eq(WasteCarriersEngine::ContactEmailValidator)
      end
    end

    describe "#confirmed_email" do
      let(:contact_email_form) { build(:contact_email_form, :has_required_data) }

      context "when a confirmed_email meets the requirements" do
        it "is valid" do
          expect(contact_email_form).to be_valid
        end
      end

      context "when a confirmed_email does not match the contact_email" do
        before(:each) { contact_email_form.confirmed_email = "no_matchy@example.com" }

        it "is not valid" do
          expect(contact_email_form).to_not be_valid
        end
      end
    end
  end
end
