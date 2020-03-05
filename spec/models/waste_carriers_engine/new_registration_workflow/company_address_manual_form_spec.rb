# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    describe "#workflow_state" do
      it_behaves_like "a manual address transition",
                      previous_state_if_overseas: :company_name_form,
                      next_state: :main_people_form,
                      address_type: "company",
                      factory: :new_registration
    end
  end
end
