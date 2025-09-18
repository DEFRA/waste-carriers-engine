# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RegisterInScotlandForms" do
    it_behaves_like "GET flexible form", "register_in_scotland_form"

    it_behaves_like "POST without params form", "register_in_scotland_form"
  end
end
