# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
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

        context "when the company_no has changed" do
          before do
            transient_registration.company_no = "01234567"
          end

          context "when the business used to be a partnership and is now an LLP" do
            before do
              transient_registration.business_type = "limitedLiabilityPartnership"
              Registration.where(reg_identifier: transient_registration.reg_identifier).first.update_attributes(business_type: "partnership")
            end

            it "changes to :company_name_form after the 'next' event" do
              expect(transient_registration).to transition_from(:registration_number_form).to(:company_name_form).on_event(:next)
            end
          end

          context "when the business is a limited_company" do
            before do
              transient_registration.business_type = "limitedCompany"
            end

            it "changes to :cannot_renew_company_no_change_form after the 'next' event" do
              expect(transient_registration).to transition_from(:registration_number_form).to(:cannot_renew_company_no_change_form).on_event(:next)
            end
          end
        end
      end
    end
  end
end
