# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    describe "#workflow_state" do

      it_behaves_like "a postcode transition",
                      address_type: "company",
                      factory: :new_registration

    end
  end
end
