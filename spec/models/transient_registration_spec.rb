require "rails_helper"

RSpec.describe TransientRegistration, type: :model do
  describe "#reg_identifier" do
    context "when a TransientRegistration is created" do
      let(:transient_registration) do
        build(:transient_registration,
              :has_required_data)
      end

      it "is not valid if the reg_identifier is in the wrong format" do
        transient_registration.reg_identifier = "foo"
        expect(transient_registration).to_not be_valid
      end

      it "is not valid if no matching registration exists" do
        transient_registration.reg_identifier = "CBDU999999"
        expect(transient_registration).to_not be_valid
      end

      it "is not valid if the reg_identifier is already in use" do
        existing_transient_registration = create(:transient_registration, :has_required_data)
        transient_registration.reg_identifier = existing_transient_registration.reg_identifier
        expect(transient_registration).to_not be_valid
      end
    end
  end

  describe "#workflow_state" do
    context "when a TransientRegistration is created" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data)
      end

      it "has the state :renewal_start_form" do
        expect(transient_registration).to have_state(:renewal_start_form)
      end
    end

    context "when a TransientRegistration's state is :renewal_start_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "renewal_start_form")
      end

      it "does not respond to the 'back' event" do
        expect(transient_registration).to_not allow_event :back
      end

      it "changes to :business_type_form after the 'next' event" do
        expect(transient_registration).to transition_from(:renewal_start_form).to(:business_type_form).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :business_type_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "business_type_form")
      end

      it "changes to :renewal_start_form after the 'back' event" do
        expect(transient_registration).to transition_from(:business_type_form).to(:renewal_start_form).on_event(:back)
      end

      context "when the business type does not change" do
        it "changes to :smart_answers_form after the 'next' event" do
          expect(transient_registration).to transition_from(:business_type_form).to(:smart_answers_form).on_event(:next)
        end
      end

      context "when the business type is originally 'authority'" do
        before(:each) do
          registration = Registration.where(reg_identifier: transient_registration.reg_identifier).first
          registration.update_attributes(business_type: "authority")
        end

        context "when the business type changes to something not requiring a new registration" do
          before(:each) do
            transient_registration.business_type = "localAuthority"
          end

          it "changes to :smart_answers_form after the 'next' event" do
            expect(transient_registration).to transition_from(:business_type_form).to(:smart_answers_form).on_event(:next)
          end
        end

        context "when the business type changes to something requiring a new registration" do
          before(:each) do
            transient_registration.business_type = "limitedCompany"
          end

          it "changes to :cannot_renew_type_change_form after the 'next' event" do
            expect(transient_registration).to transition_from(:business_type_form).to(:cannot_renew_type_change_form).on_event(:next)
          end
        end
      end

      context "when the business type is originally 'charity'" do
        before(:each) do
          registration = Registration.where(reg_identifier: transient_registration.reg_identifier).first
          registration.update_attributes(business_type: "charity")
        end

        context "when the business type changes to something not requiring a new registration" do
          before(:each) do
            transient_registration.business_type = "other"
          end

          it "changes to :cannot_renew_lower_tier_form after the 'next' event" do
            expect(transient_registration).to transition_from(:business_type_form).to(:cannot_renew_lower_tier_form).on_event(:next)
          end
        end

        context "when the business type changes to something requiring a new registration" do
          before(:each) do
            transient_registration.business_type = "limitedCompany"
          end

          it "changes to :cannot_renew_type_change_form after the 'next' event" do
            expect(transient_registration).to transition_from(:business_type_form).to(:cannot_renew_type_change_form).on_event(:next)
          end
        end
      end

      context "when the business type is originally 'limitedCompany'" do
        before(:each) do
          registration = Registration.where(reg_identifier: transient_registration.reg_identifier).first
          registration.update_attributes(business_type: "limitedCompany")
        end

        context "when the business type changes to something not requiring a new registration" do
          before(:each) do
            transient_registration.business_type = "overseas"
          end

          it "changes to :smart_answers_form after the 'next' event" do
            expect(transient_registration).to transition_from(:business_type_form).to(:smart_answers_form).on_event(:next)
          end
        end

        context "when the business type changes to something requiring a new registration" do
          before(:each) do
            transient_registration.business_type = "soleTrader"
          end

          it "changes to :cannot_renew_type_change_form after the 'next' event" do
            expect(transient_registration).to transition_from(:business_type_form).to(:cannot_renew_type_change_form).on_event(:next)
          end
        end
      end

      context "when the business type is originally 'partnership'" do
        before(:each) do
          registration = Registration.where(reg_identifier: transient_registration.reg_identifier).first
          registration.update_attributes(business_type: "partnership")
        end

        context "when the business type changes to something not requiring a new registration" do
          before(:each) do
            transient_registration.business_type = "overseas"
          end

          it "changes to :smart_answers_form after the 'next' event" do
            expect(transient_registration).to transition_from(:business_type_form).to(:smart_answers_form).on_event(:next)
          end
        end

        context "when the business type changes to something requiring a new registration" do
          before(:each) do
            transient_registration.business_type = "soleTrader"
          end

          it "changes to :cannot_renew_type_change_form after the 'next' event" do
            expect(transient_registration).to transition_from(:business_type_form).to(:cannot_renew_type_change_form).on_event(:next)
          end
        end
      end

      context "when the business type is originally 'publicBody'" do
        before(:each) do
          registration = Registration.where(reg_identifier: transient_registration.reg_identifier).first
          registration.update_attributes(business_type: "publicBody")
        end

        context "when the business type changes to something not requiring a new registration" do
          before(:each) do
            transient_registration.business_type = "localAuthority"
          end

          it "changes to :smart_answers_form after the 'next' event" do
            expect(transient_registration).to transition_from(:business_type_form).to(:smart_answers_form).on_event(:next)
          end
        end

        context "when the business type changes to something requiring a new registration" do
          before(:each) do
            transient_registration.business_type = "limitedCompany"
          end

          it "changes to :cannot_renew_type_change_form after the 'next' event" do
            expect(transient_registration).to transition_from(:business_type_form).to(:cannot_renew_type_change_form).on_event(:next)
          end
        end
      end

      context "when the business type is originally 'soleTrader'" do
        before(:each) do
          registration = Registration.where(reg_identifier: transient_registration.reg_identifier).first
          registration.update_attributes(business_type: "soleTrader")
        end

        context "when the business type changes to something not requiring a new registration" do
          before(:each) do
            transient_registration.business_type = "overseas"
          end

          it "changes to :smart_answers_form after the 'next' event" do
            expect(transient_registration).to transition_from(:business_type_form).to(:smart_answers_form).on_event(:next)
          end
        end

        context "when the business type changes to something requiring a new registration" do
          before(:each) do
            transient_registration.business_type = "limitedCompany"
          end

          it "changes to :cannot_renew_type_change_form after the 'next' event" do
            expect(transient_registration).to transition_from(:business_type_form).to(:cannot_renew_type_change_form).on_event(:next)
          end
        end
      end

      context "when the business type was originally something else" do
        before(:each) do
          registration = Registration.where(reg_identifier: transient_registration.reg_identifier).first
          registration.update_attributes(business_type: "foo")
        end

        context "when the business type changes" do
          before(:each) do
            transient_registration.business_type = "limitedCompany"
          end

          it "changes to :cannot_renew_type_change_form after the 'next' event" do
            expect(transient_registration).to transition_from(:business_type_form).to(:cannot_renew_type_change_form).on_event(:next)
          end
        end
      end
    end

    context "when a TransientRegistration's state is :smart_answers_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "smart_answers_form")
      end

      it "changes to :business_type_form after the 'back' event" do
        expect(transient_registration).to transition_from(:smart_answers_form).to(:business_type_form).on_event(:back)
      end

      it "changes to :cbd_type_form after the 'next' event" do
        expect(transient_registration).to transition_from(:smart_answers_form).to(:cbd_type_form).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :cbd_type_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "cbd_type_form")
      end

      it "changes to :smart_answers_form after the 'back' event" do
        expect(transient_registration).to transition_from(:cbd_type_form).to(:smart_answers_form).on_event(:back)
      end

      it "changes to :renewal_information_form after the 'next' event" do
        expect(transient_registration).to transition_from(:cbd_type_form).to(:renewal_information_form).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :renewal_information_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "renewal_information_form")
      end

      it "changes to :cbd_type_form after the 'back' event" do
        expect(transient_registration).to transition_from(:renewal_information_form).to(:cbd_type_form).on_event(:back)
      end

      context "when the business type is localAuthority" do
        before(:each) { transient_registration.business_type = "localAuthority" }

        it "changes to :company_name_form after the 'next' event" do
          expect(transient_registration).to transition_from(:renewal_information_form).to(:company_name_form).on_event(:next)
        end
      end

      context "when the business type is limitedCompany" do
        before(:each) { transient_registration.business_type = "limitedCompany" }

        it "changes to :registration_number_form after the 'next' event" do
          expect(transient_registration).to transition_from(:renewal_information_form).to(:registration_number_form).on_event(:next)
        end
      end

      context "when the business type is limitedLiabilityPartnership" do
        before(:each) { transient_registration.business_type = "limitedLiabilityPartnership" }

        it "changes to :registration_number_form after the 'next' event" do
          expect(transient_registration).to transition_from(:renewal_information_form).to(:registration_number_form).on_event(:next)
        end
      end

      context "when the business type is soleTrader" do
        before(:each) { transient_registration.business_type = "soleTrader" }

        it "changes to :company_name_form after the 'next' event" do
          expect(transient_registration).to transition_from(:renewal_information_form).to(:company_name_form).on_event(:next)
        end
      end
    end

    context "when a TransientRegistration's state is :registration_number_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "registration_number_form")
      end

      it "changes to :renewal_information_form after the 'back' event" do
        expect(transient_registration).to transition_from(:registration_number_form).to(:renewal_information_form).on_event(:back)
      end

      it "changes to :company_name_form after the 'next' event" do
        expect(transient_registration).to transition_from(:registration_number_form).to(:company_name_form).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :company_name_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "company_name_form")
      end

      context "when the business type is localAuthority" do
        before(:each) { transient_registration.business_type = "localAuthority" }

        it "changes to :renewal_infromation_form after the 'back' event" do
          expect(transient_registration).to transition_from(:company_name_form).to(:renewal_information_form).on_event(:back)
        end
      end

      context "when the business type is limitedCompany" do
        before(:each) { transient_registration.business_type = "limitedCompany" }

        it "changes to :registration_number_form after the 'back' event" do
          expect(transient_registration).to transition_from(:company_name_form).to(:registration_number_form).on_event(:back)
        end
      end

      context "when the business type is limitedLiabilityPartnership" do
        before(:each) { transient_registration.business_type = "limitedLiabilityPartnership" }

        it "changes to :registration_number_form after the 'back' event" do
          expect(transient_registration).to transition_from(:company_name_form).to(:registration_number_form).on_event(:back)
        end
      end

      context "when the business type is soleTrader" do
        before(:each) { transient_registration.business_type = "soleTrader" }

        it "changes to :renewal_infromation_form after the 'back' event" do
          expect(transient_registration).to transition_from(:company_name_form).to(:renewal_information_form).on_event(:back)
        end
      end

      it "changes to :company_postcode_form after the 'next' event" do
        expect(transient_registration).to transition_from(:company_name_form).to(:company_postcode_form).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :company_postcode_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "company_postcode_form")
      end

      it "changes to :company_name_form after the 'back' event" do
        expect(transient_registration).to transition_from(:company_postcode_form).to(:company_name_form).on_event(:back)
      end

      it "changes to :company_address_form after the 'next' event" do
        expect(transient_registration).to transition_from(:company_postcode_form).to(:company_address_form).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :company_address_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "company_address_form")
      end

      it "changes to :company_postcode_form after the 'back' event" do
        expect(transient_registration).to transition_from(:company_address_form).to(:company_postcode_form).on_event(:back)
      end

      it "changes to :key_people_form after the 'next' event" do
        expect(transient_registration).to transition_from(:company_address_form).to(:key_people_form).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :key_people_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "key_people_form")
      end

      it "changes to :company_address_form after the 'back' event" do
        expect(transient_registration).to transition_from(:key_people_form).to(:company_address_form).on_event(:back)
      end

      it "changes to :declare_convictions_form after the 'next' event" do
        expect(transient_registration).to transition_from(:key_people_form).to(:declare_convictions_form).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :declare_convictions_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "declare_convictions_form")
      end

      it "changes to :key_people_form after the 'back' event" do
        expect(transient_registration).to transition_from(:declare_convictions_form).to(:key_people_form).on_event(:back)
      end

      it "changes to :conviction_details_form after the 'next' event" do
        expect(transient_registration).to transition_from(:declare_convictions_form).to(:conviction_details_form).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :conviction_details_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "conviction_details_form")
      end

      it "changes to :declare_convictions_form after the 'back' event" do
        expect(transient_registration).to transition_from(:conviction_details_form).to(:declare_convictions_form).on_event(:back)
      end

      it "changes to :contact_name_form after the 'next' event" do
        expect(transient_registration).to transition_from(:conviction_details_form).to(:contact_name_form).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :contact_name_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "contact_name_form")
      end

      it "changes to :conviction_details_form after the 'back' event" do
        expect(transient_registration).to transition_from(:contact_name_form).to(:conviction_details_form).on_event(:back)
      end

      it "changes to :contact_phone_form after the 'next' event" do
        expect(transient_registration).to transition_from(:contact_name_form).to(:contact_phone_form).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :contact_phone_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "contact_phone_form")
      end

      it "changes to :contact_name_form after the 'back' event" do
        expect(transient_registration).to transition_from(:contact_phone_form).to(:contact_name_form).on_event(:back)
      end

      it "changes to :contact_email_form after the 'next' event" do
        expect(transient_registration).to transition_from(:contact_phone_form).to(:contact_email_form).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :contact_email_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "contact_email_form")
      end

      it "changes to :contact_phone_form after the 'back' event" do
        expect(transient_registration).to transition_from(:contact_email_form).to(:contact_phone_form).on_event(:back)
      end

      it "changes to :contact_address_form after the 'next' event" do
        expect(transient_registration).to transition_from(:contact_email_form).to(:contact_address_form).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :contact_address_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "contact_address_form")
      end

      it "changes to :contact_email_form after the 'back' event" do
        expect(transient_registration).to transition_from(:contact_address_form).to(:contact_email_form).on_event(:back)
      end

      it "changes to :check_your_answers_form after the 'next' event" do
        expect(transient_registration).to transition_from(:contact_address_form).to(:check_your_answers_form).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :check_your_answers_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "check_your_answers_form")
      end

      it "changes to :contact_address_form after the 'back' event" do
        expect(transient_registration).to transition_from(:check_your_answers_form).to(:contact_address_form).on_event(:back)
      end

      it "changes to :declaration_form after the 'next' event" do
        expect(transient_registration).to transition_from(:check_your_answers_form).to(:declaration_form).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :declaration_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "declaration_form")
      end

      it "changes to :check_your_answers_form after the 'back' event" do
        expect(transient_registration).to transition_from(:declaration_form).to(:check_your_answers_form).on_event(:back)
      end

      it "changes to :payment_summary_form after the 'next' event" do
        expect(transient_registration).to transition_from(:declaration_form).to(:payment_summary_form).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :payment_summary_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "payment_summary_form")
      end

      it "changes to :declaration_form after the 'back' event" do
        expect(transient_registration).to transition_from(:payment_summary_form).to(:declaration_form).on_event(:back)
      end

      it "changes to :worldpay_form after the 'next' event" do
        expect(transient_registration).to transition_from(:payment_summary_form).to(:worldpay_form).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :worldpay_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "worldpay_form")
      end

      it "changes to :payment_summary_form after the 'back' event" do
        expect(transient_registration).to transition_from(:worldpay_form).to(:payment_summary_form).on_event(:back)
      end

      it "changes to :renewal_complete_form after the 'next' event" do
        expect(transient_registration).to transition_from(:worldpay_form).to(:renewal_complete_form).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :renewal_complete_form" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "renewal_complete_form")
      end

      it "does not respond to the 'back' event" do
        expect(transient_registration).to_not allow_event :back
      end

      it "does not respond to the 'next' event" do
        expect(transient_registration).to_not allow_event :next
      end
    end
  end
end
