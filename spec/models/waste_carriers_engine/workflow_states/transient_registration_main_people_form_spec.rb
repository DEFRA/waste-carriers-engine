# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :main_people_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "main_people_form")
        end

        context "when the registered address was selected from OS Places" do
          before(:each) { transient_registration.addresses = [build(:address, :registered, :from_os_places)] }

          it "changes to :company_address_form after the 'back' event" do
            expect(transient_registration).to transition_from(:main_people_form).to(:company_address_form).on_event(:back)
          end
        end

        context "when the registered address was entered manually" do
          before(:each) { transient_registration.addresses = [build(:address, :registered, :manual_uk)] }

          it "changes to :company_address_manual_form after the 'back' event" do
            expect(transient_registration).to transition_from(:main_people_form).to(:company_address_manual_form).on_event(:back)
          end
        end

        it "changes to :declare_convictions_form after the 'next' event" do
          expect(transient_registration).to transition_from(:main_people_form).to(:declare_convictions_form).on_event(:next)
        end
      end
    end
  end
end
