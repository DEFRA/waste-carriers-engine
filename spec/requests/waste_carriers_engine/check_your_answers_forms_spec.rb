# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CheckYourAnswersForms", type: :request do
    let(:drch_validator) { instance_double(DefraRuby::Validators::CompaniesHouseService) }

    before do
      allow(DefraRuby::Validators::CompaniesHouseService).to receive(:new).and_return(drch_validator)
      allow(drch_validator).to receive(:status).and_return(:active)
    end

    include_examples "GET flexible form", "check_your_answers_form"

    include_examples "POST without params form", "check_your_answers_form"
  end
end
