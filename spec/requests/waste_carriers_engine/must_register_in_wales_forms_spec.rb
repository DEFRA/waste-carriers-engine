# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "MustRegisterInWalesForms" do
    it_behaves_like "GET flexible form", "must_register_in_wales_form"
  end
end
