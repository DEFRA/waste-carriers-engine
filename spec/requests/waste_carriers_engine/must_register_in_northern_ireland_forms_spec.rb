# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "MustRegisterInNorthernIrelandForms" do
    include_examples "GET flexible form", "must_register_in_northern_ireland_form"
  end
end
