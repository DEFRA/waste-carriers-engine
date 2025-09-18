# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration do
    subject(:renewing_registration) { build(:renewing_registration, :has_required_data, workflow_state: "business_type_form") }

    describe "#workflow_state" do
      context "with :business_type_form state transitions" do
        context "with :next transition" do
          {
            # Permutation table of old business_type, new business_type and the state that should result
            # Example where the business_type doesn't change:
            %w[limitedCompany limitedCompany] => :cbd_type_form,
            %w[charity charity] => :cbd_type_form,
            # Examples where the business_type change is allowed and not allowed:
            %w[authority localAuthority] => :cbd_type_form,
            %w[authority limitedCompany] => :cannot_renew_type_change_form,
            %w[charity limitedCompany] => :cannot_renew_type_change_form,
            %w[limitedCompany limitedLiabilityPartnership] => :cbd_type_form,
            %w[limitedCompany soleTrader] => :cannot_renew_type_change_form,
            %w[partnership limitedLiabilityPartnership] => :cannot_renew_type_change_form,
            %w[partnership soleTrader] => :cannot_renew_type_change_form,
            %w[publicBody localAuthority] => :cbd_type_form,
            %w[publicBody soleTrader] => :cannot_renew_type_change_form,
            %w[soleTrader limitedCompany] => :cannot_renew_type_change_form,
            # Example where the business_type was invalid to begin with:
            %w[foo limitedCompany] => :cannot_renew_type_change_form
          }.each do |(old_type, new_type), expected_next_state|
            context "when the old type is #{old_type} and the new type is #{new_type}" do
              before do
                # Update original business_type
                registration = Registration.where(reg_identifier: renewing_registration.reg_identifier).first
                registration.update_attributes(business_type: old_type)
                # Update new business_type
                renewing_registration.business_type = new_type
              end

              it_behaves_like "has next transition", next_state: expected_next_state
            end
          end
        end
      end
    end
  end
end
