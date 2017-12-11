require "rails_helper"

RSpec.describe TransientRegistration, type: :model do
  describe "#workflow_state" do
    context "when a TransientRegistration is created" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data)
      end

      it "has the state :renewal_start_page" do
        expect(transient_registration).to have_state(:renewal_start_page)
      end
    end

    context "when a TransientRegistration's state is :renewal_start_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "renewal_start_page")
      end

      it "does not respond to the 'back' event" do
        expect(transient_registration).to_not allow_event :back
      end

      it "changes to :business_type_page after the 'next' event" do
        expect(transient_registration).to transition_from(:renewal_start_page).to(:business_type_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :business_type_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "business_type_page")
      end

      it "changes to :renewal_start_page after the 'back' event" do
        expect(transient_registration).to transition_from(:business_type_page).to(:renewal_start_page).on_event(:back)
      end

      it "changes to :smart_answers_page after the 'next' event" do
        expect(transient_registration).to transition_from(:business_type_page).to(:smart_answers_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :smart_answers_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "smart_answers_page")
      end

      it "changes to :business_type_page after the 'back' event" do
        expect(transient_registration).to transition_from(:smart_answers_page).to(:business_type_page).on_event(:back)
      end

      it "changes to :cbd_type_page after the 'next' event" do
        expect(transient_registration).to transition_from(:smart_answers_page).to(:cbd_type_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :cbd_type_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "cbd_type_page")
      end

      it "changes to :smart_answers_page after the 'back' event" do
        expect(transient_registration).to transition_from(:cbd_type_page).to(:smart_answers_page).on_event(:back)
      end

      it "changes to :renewal_information_page after the 'next' event" do
        expect(transient_registration).to transition_from(:cbd_type_page).to(:renewal_information_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :renewal_information_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "renewal_information_page")
      end

      it "changes to :cbd_type_page after the 'back' event" do
        expect(transient_registration).to transition_from(:renewal_information_page).to(:cbd_type_page).on_event(:back)
      end

      it "changes to :registration_number_page after the 'next' event" do
        expect(transient_registration).to transition_from(:renewal_information_page).to(:registration_number_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :registration_number_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "registration_number_page")
      end

      it "changes to :renewal_information_page after the 'back' event" do
        expect(transient_registration).to transition_from(:registration_number_page).to(:renewal_information_page).on_event(:back)
      end

      it "changes to :company_name_page after the 'next' event" do
        expect(transient_registration).to transition_from(:registration_number_page).to(:company_name_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :company_name_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "company_name_page")
      end

      it "changes to :registration_number_page after the 'back' event" do
        expect(transient_registration).to transition_from(:company_name_page).to(:registration_number_page).on_event(:back)
      end

      it "changes to :company_postcode_page after the 'next' event" do
        expect(transient_registration).to transition_from(:company_name_page).to(:company_postcode_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :company_postcode_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "company_postcode_page")
      end

      it "changes to :company_name_page after the 'back' event" do
        expect(transient_registration).to transition_from(:company_postcode_page).to(:company_name_page).on_event(:back)
      end

      it "changes to :company_address_page after the 'next' event" do
        expect(transient_registration).to transition_from(:company_postcode_page).to(:company_address_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :company_address_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "company_address_page")
      end

      it "changes to :company_postcode_page after the 'back' event" do
        expect(transient_registration).to transition_from(:company_address_page).to(:company_postcode_page).on_event(:back)
      end

      it "changes to :key_people_director_page after the 'next' event" do
        expect(transient_registration).to transition_from(:company_address_page).to(:key_people_director_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :key_people_director_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "key_people_director_page")
      end

      it "changes to :company_address_page after the 'back' event" do
        expect(transient_registration).to transition_from(:key_people_director_page).to(:company_address_page).on_event(:back)
      end

      it "changes to :declare_convictions_page after the 'next' event" do
        expect(transient_registration).to transition_from(:key_people_director_page).to(:declare_convictions_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :declare_convictions_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "declare_convictions_page")
      end

      it "changes to :key_people_director_page after the 'back' event" do
        expect(transient_registration).to transition_from(:declare_convictions_page).to(:key_people_director_page).on_event(:back)
      end

      it "changes to :conviction_details_page after the 'next' event" do
        expect(transient_registration).to transition_from(:declare_convictions_page).to(:conviction_details_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :conviction_details_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "conviction_details_page")
      end

      it "changes to :declare_convictions_page after the 'back' event" do
        expect(transient_registration).to transition_from(:conviction_details_page).to(:declare_convictions_page).on_event(:back)
      end

      it "changes to :contact_name_page after the 'next' event" do
        expect(transient_registration).to transition_from(:conviction_details_page).to(:contact_name_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :contact_name_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "contact_name_page")
      end

      it "changes to :conviction_details_page after the 'back' event" do
        expect(transient_registration).to transition_from(:contact_name_page).to(:conviction_details_page).on_event(:back)
      end

      it "changes to :contact_phone_page after the 'next' event" do
        expect(transient_registration).to transition_from(:contact_name_page).to(:contact_phone_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :contact_phone_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "contact_phone_page")
      end

      it "changes to :contact_name_page after the 'back' event" do
        expect(transient_registration).to transition_from(:contact_phone_page).to(:contact_name_page).on_event(:back)
      end

      it "changes to :contact_email_page after the 'next' event" do
        expect(transient_registration).to transition_from(:contact_phone_page).to(:contact_email_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :contact_email_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "contact_email_page")
      end

      it "changes to :contact_phone_page after the 'back' event" do
        expect(transient_registration).to transition_from(:contact_email_page).to(:contact_phone_page).on_event(:back)
      end

      it "changes to :contact_address_page after the 'next' event" do
        expect(transient_registration).to transition_from(:contact_email_page).to(:contact_address_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :contact_address_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "contact_address_page")
      end

      it "changes to :contact_email_page after the 'back' event" do
        expect(transient_registration).to transition_from(:contact_address_page).to(:contact_email_page).on_event(:back)
      end

      it "changes to :check_your_answers_page after the 'next' event" do
        expect(transient_registration).to transition_from(:contact_address_page).to(:check_your_answers_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :check_your_answers_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "check_your_answers_page")
      end

      it "changes to :contact_address_page after the 'back' event" do
        expect(transient_registration).to transition_from(:check_your_answers_page).to(:contact_address_page).on_event(:back)
      end

      it "changes to :declaration_page after the 'next' event" do
        expect(transient_registration).to transition_from(:check_your_answers_page).to(:declaration_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :declaration_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "declaration_page")
      end

      it "changes to :check_your_answers_page after the 'back' event" do
        expect(transient_registration).to transition_from(:declaration_page).to(:check_your_answers_page).on_event(:back)
      end

      it "changes to :payment_summary_page after the 'next' event" do
        expect(transient_registration).to transition_from(:declaration_page).to(:payment_summary_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :payment_summary_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "payment_summary_page")
      end

      it "changes to :declaration_page after the 'back' event" do
        expect(transient_registration).to transition_from(:payment_summary_page).to(:declaration_page).on_event(:back)
      end

      it "changes to :worldpay_page after the 'next' event" do
        expect(transient_registration).to transition_from(:payment_summary_page).to(:worldpay_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :worldpay_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "worldpay_page")
      end

      it "changes to :payment_summary_page after the 'back' event" do
        expect(transient_registration).to transition_from(:worldpay_page).to(:payment_summary_page).on_event(:back)
      end

      it "changes to :renewal_complete_page after the 'next' event" do
        expect(transient_registration).to transition_from(:worldpay_page).to(:renewal_complete_page).on_event(:next)
      end
    end

    context "when a TransientRegistration's state is :renewal_complete_page" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "renewal_complete_page")
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
