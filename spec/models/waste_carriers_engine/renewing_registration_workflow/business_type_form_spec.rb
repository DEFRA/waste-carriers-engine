# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    describe "#workflow_state" do
      context "when a RenewingRegistration's state is :business_type_form" do
        let(:transient_registration) do
          create(:renewing_registration,
                 :has_required_data,
                 workflow_state: "business_type_form")
        end

        context "when the 'back' event happens" do
          shared_examples_for "'back' transition from business_type_form" do |location, back_state|
            before(:each) do
              transient_registration.location = location
            end

            it "should transition to the correct back state" do
              expect(transient_registration).to transition_from(:business_type_form).to(back_state).on_event(:back)
            end
          end

          {
            # Permutation table of location and the state that should result
            "england" => :location_form,
            "northern_ireland" => :register_in_northern_ireland_form,
            "scotland" => :register_in_scotland_form,
            "wales" => :register_in_wales_form
          }.each do |location, back_form|
            it_behaves_like "'back' transition from business_type_form", location, back_form
          end
        end

        context "when the 'next' event happens" do
          shared_examples_for "'next' transition from business_type_form" do |(old_type, new_type), next_state|
            before(:each) do
              # Update original business_type
              registration = Registration.where(reg_identifier: transient_registration.reg_identifier).first
              registration.update_attributes(business_type: old_type)
              # Update new business_type
              transient_registration.business_type = new_type
            end

            it "should transition to the correct next state" do
              expect(transient_registration).to transition_from(:business_type_form).to(next_state).on_event(:next)
            end
          end

          {
            # Permutation table of old business_type, new business_type and the state that should result
            # Example where the business_type doesn't change:
            %w[limitedCompany limitedCompany] => :tier_check_form,
            %w[charity charity] => :cannot_renew_lower_tier_form,
            # Examples where the business_type change is allowed and not allowed:
            %w[authority localAuthority] => :tier_check_form,
            %w[authority limitedCompany] => :cannot_renew_type_change_form,
            %w[charity limitedCompany] => :cannot_renew_type_change_form,
            %w[limitedCompany limitedLiabilityPartnership] => :tier_check_form,
            %w[limitedCompany soleTrader] => :cannot_renew_type_change_form,
            %w[partnership limitedLiabilityPartnership] => :tier_check_form,
            %w[partnership soleTrader] => :cannot_renew_type_change_form,
            %w[publicBody localAuthority] => :tier_check_form,
            %w[publicBody soleTrader] => :cannot_renew_type_change_form,
            %w[soleTrader limitedCompany] => :cannot_renew_type_change_form,
            # Example where the business_type was invalid to begin with:
            %w[foo limitedCompany] => :cannot_renew_type_change_form
          }.each do |business_types, next_form|
            it_behaves_like "'next' transition from business_type_form", business_types, next_form
          end
        end
      end
    end
  end
end
