# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            workflow_state: "registration_number_form")
    end

    describe "#workflow_state" do
      context ":registration_number_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "check_registered_company_name_form"

          context "when the company_no has changed" do
            before { subject.company_no = "01234567" }

            include_examples "has next transition", next_state: "cannot_renew_company_no_change_form"

            context "when the business used to be a partnership and is now an LLP" do
              before do
                subject.business_type = "limitedLiabilityPartnership"
                subject.registration.update_attributes(business_type: "partnership")
              end

              include_examples "has next transition", next_state: "check_registered_company_name_form"
            end
          end

          context "when the old company_no had trailing whitespace in it" do
            before do
              subject.registration.update_attributes(company_no: "#{subject.company_no} ")
            end

            include_examples "has next transition", next_state: "check_registered_company_name_form"
          end
        end

        context "on back" do
          include_examples "has back transition", previous_state: "renewal_information_form"
        end
      end
    end
  end
end
