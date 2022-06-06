# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CheckYourAnswersForms", type: :request do
    before do
      allow_any_instance_of(DefraRuby::Validators::CompaniesHouseService).to receive(:status).and_return(:active)
    end

    include_examples "GET flexible form", "check_your_answers_form"

    include_examples "POST without params form", "check_your_answers_form"
  end
end
