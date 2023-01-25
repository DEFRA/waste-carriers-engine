# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RegisterInNorthernIrelandForms" do
    include_examples "GET flexible form", "register_in_northern_ireland_form"

    include_examples "POST without params form", "register_in_northern_ireland_form"
  end
end
