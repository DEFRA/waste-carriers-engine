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
          confirmed_email: confirmed_email,
          no_contact_email: defined?(no_contact_email) ? no_contact_email : nil
        }
      end
      let(:confirmed_email) { contact_email }

      shared_examples "should submit" do
        it "submits the form successfully" do
          expect(contact_email_form.submit(ActionController::Parameters.new(params))).to be true
        end
      end

      shared_examples "should submit and populate the contact_email" do
        it "submits the form successfully" do
          expect(contact_email_form.submit(ActionController::Parameters.new(params))).to be true
        end

        it "populates the contact_email" do
          expect { contact_email_form.submit(ActionController::Parameters.new(params)) }
            .to change { contact_email_form.transient_registration.contact_email }.to(contact_email.strip)
        end
      end

      shared_examples "should not submit" do
        it "does not submit the form successfully" do
          expect(contact_email_form.submit(ActionController::Parameters.new(params))).to be false
        end
      end

      context "when the form is valid" do
        before { contact_email_form.transient_registration.contact_email = nil }

        context "when running in the front office" do
          before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(false) }

          context "with an email address" do
            let(:contact_email) { Faker::Internet.email }

            it_behaves_like "should submit and populate the contact_email"
          end

          context "with whitespace around the email address" do
            let(:actual_email) { Faker::Internet.email }
            let(:contact_email) { "  #{actual_email} " }
            let(:confirmed_email) { actual_email }

            it_behaves_like "should submit and populate the contact_email"
          end

          context "with whitespace around the confirmed email address" do
            let(:contact_email) { Faker::Internet.email }
            let(:confirmed_email) { "#{contact_email} " }

            it_behaves_like "should submit and populate the contact_email"
          end
        end

        context "when running in the back office" do
          before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(true) }

          context "with an email address" do
            let(:contact_email) { Faker::Internet.email }

            it_behaves_like "should submit and populate the contact_email"
          end

          context "with a blank email address" do
            let(:contact_email) { "" }
            let(:no_contact_email) { "1" }

            it_behaves_like "should submit"

            it "does not populate contact_email" do
              expect { contact_email_form.submit(ActionController::Parameters.new(params)) }
                .not_to change { contact_email_form.transient_registration.contact_email }.from(nil)
            end
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
            let(:contact_email) { Faker::Internet.email }
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
        before { contact_email_form.confirmed_email = "no_matchy@example.com" }

        it "is not valid" do
          expect(contact_email_form).not_to be_valid
        end
      end
    end
  end
end
