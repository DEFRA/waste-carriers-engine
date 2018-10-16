require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EntityMatchingService do
    let(:transient_registration) do
      create(:transient_registration,
             :has_required_data,
             :has_matching_convictions)
    end

    let(:entity_matching_service) { EntityMatchingService.new(transient_registration) }

    describe "check_business_for_matches" do
      context "when there is a match" do
        it "creates a valid conviction_search_result for the business" do
          VCR.use_cassette("entity_matching_business_has_matches") do
            entity_matching_service.check_business_for_matches
            expect(transient_registration.reload.conviction_search_result.match_result).to eq("YES")
          end
        end
      end

      context "when there is no match" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 :has_key_people)
        end

        it "creates a valid conviction_search_result for the business" do
          VCR.use_cassette("entity_matching_business_no_matches") do
            entity_matching_service.check_business_for_matches
            expect(transient_registration.reload.conviction_search_result.match_result).to eq("NO")
          end
        end
      end
    end

    describe "check_people_for_matches" do
      context "when there is a match" do
        it "creates a valid conviction_search_result for the person" do
          VCR.use_cassette("entity_matching_person_has_matches") do
            entity_matching_service.check_people_for_matches
            expect(transient_registration.reload.key_people.first.conviction_search_result.match_result).to eq("YES")
          end
        end
      end

      context "when there is no match" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 :has_key_people)
        end

        it "creates a valid conviction_search_result for the person" do
          VCR.use_cassette("entity_matching_person_no_matches") do
            entity_matching_service.check_people_for_matches
            expect(transient_registration.reload.key_people.first.conviction_search_result.match_result).to eq("NO")
          end
        end
      end

      context "when a person's name contains unicode characters" do
        before do
          transient_registration.key_people.first.first_name = "José"
        end

        it "escapes the unicode characters and creates a valid conviction_search_result for the person" do
          VCR.use_cassette("entity_matching_person_unicode") do
            entity_matching_service.check_people_for_matches
            expect(transient_registration.reload.key_people.first.conviction_search_result.match_result).to eq("NO")
          end
        end
      end

      context "when the response cannot be parsed as JSON" do
        before do
          allow_any_instance_of(RestClient::Request).to receive(:execute).and_return("foo")
        end

        it "creates a new conviction_search_result" do
          entity_matching_service.check_people_for_matches
          expect(transient_registration.reload.key_people.first.conviction_search_result.match_result).to eq("UNKNOWN")
        end
      end

      context "when the request times out" do
        it "creates a new conviction_search_result" do
          VCR.turned_off do
            host = Rails.configuration.wcrs_services_url
            stub_request(:any, /.*#{host}.*/).to_timeout

            entity_matching_service.check_people_for_matches
            expect(transient_registration.reload.key_people.first.conviction_search_result.match_result).to eq("UNKNOWN")
          end
        end
      end

      context "when the request returns an error" do
        it "creates a new conviction_search_result" do
          VCR.turned_off do
            host = Rails.configuration.wcrs_services_url
            stub_request(:any, /.*#{host}.*/).to_raise(SocketError)

            entity_matching_service.check_people_for_matches
            expect(transient_registration.reload.key_people.first.conviction_search_result.match_result).to eq("UNKNOWN")
          end
        end
      end
    end
  end
end
