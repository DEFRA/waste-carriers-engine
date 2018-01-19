require "rails_helper"

RSpec.describe TransientRegistration, type: :model do
  context "when a TransientRegistration's state is :business_type_form" do
    let(:transient_registration) do
      create(:transient_registration,
             :has_required_data,
             workflow_state: "business_type_form")
    end

    context "when the 'back' event happens" do
      it "changes to :renewal_start_form" do
        expect(transient_registration).to transition_from(:business_type_form).to(:renewal_start_form).on_event(:back)
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
        %w[limitedCompany limitedCompany] => :other_businesses_form,
        # Examples where the business_type change is allowed and not allowed:
        %w[authority localAuthority]      => :other_businesses_form,
        %w[authority limitedCompany]      => :cannot_renew_type_change_form,
        %w[charity other]                 => :cannot_renew_lower_tier_form,
        %w[charity limitedCompany]        => :cannot_renew_type_change_form,
        %w[limitedCompany overseas]       => :other_businesses_form,
        %w[limitedCompany soleTrader]     => :cannot_renew_type_change_form,
        %w[partnership overseas]          => :other_businesses_form,
        %w[partnership soleTrader]        => :cannot_renew_type_change_form,
        %w[publicBody localAuthority]     => :other_businesses_form,
        %w[publicBody soleTrader]         => :cannot_renew_type_change_form,
        # Example where the business_type was invalid to begin with:
        %w[foo limitedCompany]            => :cannot_renew_type_change_form
      }.each do |business_types, next_form|
        it_behaves_like "'next' transition from business_type_form", business_types, next_form
      end
    end
  end
end
