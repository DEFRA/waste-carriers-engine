# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EntityMatchingService do
    let(:key_person) { build(:key_person) }
    let(:transient_registration) do
      create(:renewing_registration,
             :has_required_data,
             key_people: [key_person])
    end

    before do
      allow(ConvictionsCheck::OrganisationMatchService).to receive(:run).and_return(match_result: "YES")
      allow(ConvictionsCheck::PersonMatchService).to receive(:run).and_return(match_result: "YES")
    end

    describe "run" do
      it "creates valid conviction_search_results" do

        described_class.run(transient_registration)

        expect(ConvictionsCheck::OrganisationMatchService).to have_received(:run)
          .with(name: transient_registration.company_name, company_no: transient_registration.company_no)
        expect(ConvictionsCheck::PersonMatchService).to have_received(:run)
          .with(first_name: key_person.first_name, last_name: key_person.last_name, date_of_birth: key_person.dob)

        expect(transient_registration.reload.conviction_search_result.match_result).to eq("YES")
        expect(transient_registration.reload.key_people.first.conviction_search_result.match_result).to eq("YES")
      end
    end
  end
end
