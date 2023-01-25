# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CheckYourAnswersForm do
    let(:companies_house_validator) { instance_double(DefraRuby::Validators::CompaniesHouseService) }

    before do
      allow(DefraRuby::Validators::CompaniesHouseService).to receive(:new).and_return(companies_house_validator)
      allow(companies_house_validator).to receive(:status).and_return(:active)
    end

    describe "#submit" do
      let(:check_your_answers_form) { build(:check_your_answers_form, :has_required_data) }

      context "when the form is valid" do
        let(:valid_params) { { token: check_your_answers_form.token } }

        it "submits" do
          expect(check_your_answers_form.submit(valid_params)).to be_truthy
        end
      end

      context "when the form is not valid" do
        before do
          allow(check_your_answers_form).to receive(:valid?).and_return(false)
        end

        it "does not submit" do
          expect(check_your_answers_form.submit({})).to be_falsey
        end
      end
    end

    include_examples "validate yes no", :check_your_answers_form, :declared_convictions
    include_examples "validate business_type", :check_your_answers_form
    include_examples "validate company_name", :check_your_answers_form
    include_examples "validate location", :check_your_answers_form
    include_examples "validate person name", :check_your_answers_form, :first_name
    include_examples "validate person name", :check_your_answers_form, :last_name
    include_examples "validate phone_number", :check_your_answers_form
    include_examples "validate registration_type", :check_your_answers_form

    context "when a valid transient registration exists" do
      let(:check_your_answers_form) { build(:check_your_answers_form, :has_required_data) }

      context "when all fields meet the requirements" do
        it "is valid" do
          expect(check_your_answers_form).to be_valid
        end
      end

      describe "#registered_address" do
        context "when there is no registered_address" do
          before do
            check_your_answers_form.transient_registration.registered_address = nil
          end

          it "is not valid" do
            expect(check_your_answers_form).not_to be_valid
          end
        end

        context "when the location is in the uk" do
          context "when the registered_address mode is manual-uk" do
            before do
              check_your_answers_form.transient_registration.registered_address = build(:address, :registered, :manual_uk)
            end

            it "is valid" do
              expect(check_your_answers_form).to be_valid
            end
          end

          context "when the registered_address mode is address-lookup" do
            before do
              check_your_answers_form.transient_registration.registered_address = build(:address, :registered, :from_os_places)
            end

            it "is valid" do
              expect(check_your_answers_form).to be_valid
            end
          end

          context "when the registered_address mode is manual-foreign" do
            before do
              check_your_answers_form.transient_registration.registered_address = build(:address, :registered, :manual_foreign)
            end

            it "is not valid" do
              expect(check_your_answers_form).not_to be_valid
            end
          end
        end

        context "when the location is overseas" do
          let(:check_your_answers_form) { build(:check_your_answers_form, :has_required_overseas_data) }

          context "when the registered_address mode is manual-foreign" do
            before do
              check_your_answers_form.transient_registration.registered_address = build(:address, :registered, :manual_foreign)
            end

            it "is valid" do
              expect(check_your_answers_form).to be_valid
            end
          end

          context "when the registered_address mode is manual-uk" do
            before do
              check_your_answers_form.transient_registration.registered_address = build(:address, :registered, :manual_uk)
            end

            it "is not valid" do
              expect(check_your_answers_form).not_to be_valid
            end
          end

          context "when the registered_address mode is address-lookup" do
            before do
              check_your_answers_form.transient_registration.registered_address = build(:address, :registered, :from_os_places)
            end

            it "is not valid" do
              expect(check_your_answers_form).not_to be_valid
            end
          end
        end
      end

      describe "#contact_address" do
        context "when there is no contact_address" do
          before do
            check_your_answers_form.transient_registration.contact_address = nil
          end

          it "is not valid" do
            expect(check_your_answers_form).not_to be_valid
          end
        end

        context "when the location is in the uk" do
          context "when the contact_address mode is manual-uk" do
            before do
              check_your_answers_form.transient_registration.contact_address = build(:address, :contact, :manual_uk)
            end

            it "is valid" do
              expect(check_your_answers_form).to be_valid
            end
          end

          context "when the contact_address mode is address-lookup" do
            before do
              check_your_answers_form.transient_registration.contact_address = build(:address, :contact, :from_os_places)
            end

            it "is valid" do
              expect(check_your_answers_form).to be_valid
            end
          end

          context "when the contact_address mode is manual-foreign" do
            before do
              check_your_answers_form.transient_registration.contact_address = build(:address, :contact, :manual_foreign)
            end

            it "is not valid" do
              expect(check_your_answers_form).not_to be_valid
            end
          end
        end

        context "when the location is overseas" do
          let(:check_your_answers_form) { build(:check_your_answers_form, :has_required_overseas_data) }

          context "when the contact_address mode is manual-foreign" do
            before do
              check_your_answers_form.transient_registration.contact_address = build(:address, :contact, :manual_foreign)
            end

            it "is valid" do
              expect(check_your_answers_form).to be_valid
            end
          end

          context "when the contact_address mode is manual-uk" do
            before do
              check_your_answers_form.transient_registration.contact_address = build(:address, :contact, :manual_uk)
            end

            it "is not valid" do
              expect(check_your_answers_form).not_to be_valid
            end
          end

          context "when the contact_address mode is address-lookup" do
            before do
              check_your_answers_form.transient_registration.contact_address = build(:address, :contact, :from_os_places)
            end

            it "is not valid" do
              expect(check_your_answers_form).not_to be_valid
            end
          end
        end
      end

      describe "#contact_email" do
        context "when running in the front office" do
          before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(false) }

          include_examples "validate email", :check_your_answers_form, :contact_email
        end

        context "when running in the back office" do
          before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(true) }

          it "validates the contact_email using the OptionalEmailValidator class" do
            expect(check_your_answers_form._validators[:contact_email].map(&:class))
              .to include(WasteCarriersEngine::OptionalEmailValidator)
          end
        end
      end

      describe "#main_people" do
        context "when there are no main_people" do
          before do
            check_your_answers_form.transient_registration.key_people = nil
          end

          it "is not valid" do
            expect(check_your_answers_form).not_to be_valid
          end
        end

        context "when the main_people are missing information" do
          before do
            main_person = build(:key_person, :main)

            check_your_answers_form.transient_registration.key_people = [main_person]
          end

          it "is not valid" do
            expect(check_your_answers_form).not_to be_valid
          end
        end

        context "when there is one main_people" do
          before do
            main_person = build(:key_person, :has_required_data, :main)

            check_your_answers_form.transient_registration.key_people = [main_person]
          end

          context "when the business type is not partnership" do
            it "is valid" do
              expect(check_your_answers_form).to be_valid
            end
          end

          context "when the business type is partnership" do
            before do
              check_your_answers_form.transient_registration.business_type = "partnership"
            end

            it "is not valid" do
              expect(check_your_answers_form).not_to be_valid
            end
          end
        end

        context "when there are two main_people" do
          before do
            main_person_a = build(:key_person, :has_required_data, :main)
            main_person_b = build(:key_person, :has_required_data, :main)

            check_your_answers_form.transient_registration.key_people = [main_person_a, main_person_b]
          end

          context "when the business type is not soleTrader" do
            it "is valid" do
              expect(check_your_answers_form).to be_valid
            end
          end

          context "when the business type is soleTrader" do
            before do
              check_your_answers_form.transient_registration.business_type = "soleTrader"
            end

            it "is not valid" do
              expect(check_your_answers_form).not_to be_valid
            end
          end
        end
      end

      describe "#relevant_people" do
        let(:main_person) { build(:key_person, :has_required_data, :main) }

        context "when there are no relevant_people" do
          before do
            check_your_answers_form.transient_registration.key_people = [main_person]
          end

          context "when declared_convictions does not expect there to be people" do
            before do
              check_your_answers_form.transient_registration.declared_convictions = "no"
            end

            it "is valid" do
              expect(check_your_answers_form).to be_valid
            end
          end

          context "when declared_convictions expects there to be people" do
            before do
              check_your_answers_form.transient_registration.declared_convictions = "yes"
            end

            it "is not valid" do
              expect(check_your_answers_form).not_to be_valid
            end
          end
        end

        context "when there is a valid relevant_people" do
          before do
            relevant_person = build(:key_person, :has_required_data, :relevant)

            check_your_answers_form.transient_registration.key_people = [main_person, relevant_person]
          end

          it "is valid" do
            expect(check_your_answers_form).to be_valid
          end
        end

        context "when the relevant_people are missing information" do
          before do
            relevant_person = build(:key_person, :relevant)

            check_your_answers_form.transient_registration.key_people = [main_person, relevant_person]
          end

          it "is not valid" do
            expect(check_your_answers_form).not_to be_valid
          end
        end
      end

      describe "#company_name" do
        context "without a company name" do
          before do
            check_your_answers_form.transient_registration.company_name = nil
            check_your_answers_form.transient_registration.temp_use_trading_name = "no"
          end

          context "with an upper tier registration" do
            before { check_your_answers_form.transient_registration.tier = "UPPER" }

            context "when based in England" do
              before { check_your_answers_form.transient_registration.location = "england" }

              it "is valid" do
                expect(check_your_answers_form).to be_valid
              end
            end

            context "when based overseas" do
              before { check_your_answers_form.transient_registration.location = "overseas" }

              it "is not valid" do
                expect(check_your_answers_form).not_to be_valid
              end
            end
          end

          context "with a lower tier registration" do
            before { check_your_answers_form.transient_registration.tier = "LOWER" }

            it "is not valid" do
              expect(check_your_answers_form).not_to be_valid
            end
          end
        end
      end

      context "when the business type has an invalid change" do
        before do
          check_your_answers_form.transient_registration.business_type = "limitedCompany"
          check_your_answers_form.transient_registration.registration.update_attributes(business_type: "soleTrader")
        end

        it "is not valid" do
          expect(check_your_answers_form).not_to be_valid
        end
      end

      context "when the business type has changed to charity" do
        before do
          check_your_answers_form.transient_registration.business_type = "charity"
        end

        it "is not valid" do
          expect(check_your_answers_form).not_to be_valid
        end
      end
    end

    describe "custom_error_messages" do
      it "gets the correct error" do
        hash = { inclusion: "Select a valid principal place of business" }

        expect(described_class.custom_error_messages(:location, :inclusion)).to eq(hash)
      end
    end
  end
end
