# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            location: location,
            workflow_state: "location_form")
    end
    let(:location) {}

    describe "#workflow_state" do
      context ":location_form state transitions" do
        context "on next" do

          { # Permutation table of location and the state that should result
            "england" => :business_type_form,
            "northern_ireland" => :register_in_northern_ireland_form,
            "scotland" => :register_in_scotland_form,
            "wales" => :register_in_wales_form,
            "overseas" => :tier_check_form
          }.each do |location, expected_next_state|
            context "when the location is #{location}" do
              let(:location) { location }

              include_examples "has next transition", next_state: expected_next_state
            end
          end
        end

        context "on back" do
          include_examples "has back transition", previous_state: "renewal_start_form"
        end
      end
    end
  end
end
