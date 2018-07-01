require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :company_name_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "company_name_form")
        end

        context "when the business type is localAuthority" do
          before(:each) { transient_registration.business_type = "localAuthority" }

          it "changes to :renewal_information_form after the 'back' event" do
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

        context "when the business type is partnership" do
          before(:each) { transient_registration.business_type = "partnership" }

          it "changes to :renewal_information_form after the 'back' event" do
            expect(transient_registration).to transition_from(:company_name_form).to(:renewal_information_form).on_event(:back)
          end
        end

        context "when the business type is soleTrader" do
          before(:each) { transient_registration.business_type = "soleTrader" }

          it "changes to :renewal_information_form after the 'back' event" do
            expect(transient_registration).to transition_from(:company_name_form).to(:renewal_information_form).on_event(:back)
          end
        end

        context "when the location is overseas" do
          before(:each) { transient_registration.location = "overseas" }

          it "changes to :renewal_information_form after the 'back' event" do
            expect(transient_registration).to transition_from(:company_name_form).to(:renewal_information_form).on_event(:back)
          end

          it "changes to :company_address_manual_form after the 'next' event" do
            expect(transient_registration).to transition_from(:company_name_form).to(:company_address_manual_form).on_event(:next)
          end
        end

        context "when the location is not overseas" do
          before(:each) { transient_registration.location = "england" }

          it "changes to :company_postcode_form after the 'next' event" do
            expect(transient_registration).to transition_from(:company_name_form).to(:company_postcode_form).on_event(:next)
          end
        end
      end
    end
  end
end
