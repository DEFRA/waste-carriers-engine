# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration, type: :model do
    subject(:new_registration) { build(:new_registration) }

    describe "scopes" do
      it_should_behave_like "TransientRegistration named scopes"
    end
  end
end
