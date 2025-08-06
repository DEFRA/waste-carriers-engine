# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RegisterInWalesForms" do
    it_behaves_like "GET flexible form", "register_in_wales_form"

    it_behaves_like "POST without params form", "register_in_wales_form"
  end
end
