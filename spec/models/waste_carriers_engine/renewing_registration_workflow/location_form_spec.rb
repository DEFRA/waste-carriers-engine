# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration do
    subject do
      build(:renewing_registration,
            :has_required_data,
            location: location,
            workflow_state: "location_form")
    end
    let(:location) { nil }

    describe "#workflow_state" do
      context "with :location_form state transitions" do
        context "with :next transition" do

          { # Permutation table of location and the state that should result
            "england" => :business_type_form,
            "northern_ireland" => :register_in_northern_ireland_form,
            "scotland" => :register_in_scotland_form,
            "wales" => :register_in_wales_form,
            "overseas" => :cbd_type_form
          }.each do |location, expected_next_state|
            context "when the location is #{location}" do
              let(:location) { location }

              it_behaves_like "has next transition", next_state: expected_next_state
            end
          end
        end
      end
    end
  end
end
