# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CannotRenewTypeChangeForms" do
    it_behaves_like "GET flexible form", "cannot_renew_type_change_form"
  end
end
