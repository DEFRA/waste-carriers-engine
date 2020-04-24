# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    describe "#workflow_state" do
      context "when a RenewingRegistration's state is :renewal_information_form" do
        let(:transient_registration) do
          create(:renewing_registration,
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

        context "when the location is overseas" do
          before(:each) { transient_registration.location = "overseas" }

          it "changes to :company_name_form after the 'next' event" do
            expect(transient_registration).to transition_from(:renewal_information_form).to(:company_name_form).on_event(:next)
          end
        end

        context "when the business type is partnership" do
          before(:each) { transient_registration.business_type = "partnership" }

          it "changes to :company_name_form after the 'next' event" do
            expect(transient_registration).to transition_from(:renewal_information_form).to(:company_name_form).on_event(:next)
          end
        end

        context "when the business type is soleTrader" do
          before(:each) { transient_registration.business_type = "soleTrader" }

          it "changes to :company_name_form after the 'next' event" do
            expect(transient_registration).to transition_from(:renewal_information_form).to(:company_name_form).on_event(:next)
          end
        end
      end
    end
  end
end
