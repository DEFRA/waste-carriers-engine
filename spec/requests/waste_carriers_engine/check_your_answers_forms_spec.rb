# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CheckYourAnswersForms" do
    let(:drch_validator) { instance_double(DefraRuby::Validators::CompaniesHouseService) }

    before do
      allow(DefraRuby::Validators::CompaniesHouseService).to receive(:new).and_return(drch_validator)
      allow(drch_validator).to receive(:status).and_return(:active)
    end

    it_behaves_like "GET flexible form", "check_your_answers_form"

    it_behaves_like "POST without params form", "check_your_answers_form"
  end
end
