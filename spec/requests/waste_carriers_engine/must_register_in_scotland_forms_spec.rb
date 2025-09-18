# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "MustRegisterInScotlandForms" do
    it_behaves_like "GET flexible form", "must_register_in_scotland_form"
  end
end
