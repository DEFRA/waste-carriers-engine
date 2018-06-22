require "rails_helper"

RSpec.describe EntityMatchingService do
  let(:transient_registration) do
    create(:transient_registration,
           :has_required_data,
           :has_matching_convictions)
  end

  let(:entity_matching_service) { EntityMatchingService.new(transient_registration) }

  let(:error_data) do
    {
      match_result: "UNKNOWN",
      matching_system: "ERROR",
      searched_at: Time.now.to_i,
      confirmed: "no"
    }
  end

  describe "check_business_for_matches" do
    context "when there is no company_no" do
      before do
        transient_registration.company_no = nil
      end

      let(:match_data) do
        {
          "confirmed" => "no",
          "confirmed_at" => nil,
          "confirmed_by" => nil,
          "match_result" => "YES",
          "matched_name" => "Test Waste Services Ltd.",
          "matching_system" => "PQR",
          "reference" => "7766",
          "searched_at" => 1529667048440
        }
      end

      it "returns the correct data" do
        VCR.use_cassette("entity_matching_business_has_matches") do
          expect(entity_matching_service.check_business_for_matches).to include(match_data)
        end
      end
    end
  end

  describe "check_people_for_matches" do
    context "when there is a match" do
      let(:match_data) do
        {
          "confirmed" => "no",
          "confirmed_at" => nil,
          "confirmed_by" => nil,
          "match_result" => "YES",
          "matched_name" => "Blogs, Fred",
          "matching_system" => "ABC",
          "reference" => "1234"
        }
      end

      it "returns the correct data" do
        VCR.use_cassette("entity_matching_person_has_matches") do
          expect(entity_matching_service.check_people_for_matches).to include(match_data)
        end
      end
    end

    context "when there is no match" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               :has_key_people)
      end

      let(:match_data) do
        {
          "confirmed" => "no",
          "confirmed_at" => nil,
          "confirmed_by" => nil,
          "match_result" => "NO",
          "matched_name" => nil,
          "matching_system" => nil,
          "reference" => nil
        }
      end

      it "returns the correct data" do
        VCR.use_cassette("entity_matching_person_no_matches") do
          expect(entity_matching_service.check_people_for_matches).to include(match_data)
        end
      end
    end

    context "when the response cannot be parsed as JSON" do
      before do
        allow_any_instance_of(RestClient::Request).to receive(:execute).and_return("foo")
      end

      it "returns error_data" do
        expect(entity_matching_service.check_people_for_matches).to eq(error_data)
      end
    end

    context "when the request times out" do
      it "returns error_data" do
        VCR.turned_off do
          host = Rails.configuration.wcrs_services_url
          stub_request(:any, /.*#{host}.*/).to_timeout
          expect(entity_matching_service.check_people_for_matches).to eq(error_data)
        end
      end
    end

    context "when the request returns a connection refused error" do
      it "returns error_data" do
        VCR.turned_off do
          host = Rails.configuration.wcrs_services_url
          stub_request(:any, /.*#{host}.*/).to_raise(Errno::ECONNREFUSED)
          expect(entity_matching_service.check_people_for_matches).to eq(error_data)
        end
      end
    end

    context "when the request returns a socket error" do
      it "returns error_data" do
        VCR.turned_off do
          host = Rails.configuration.wcrs_services_url
          stub_request(:any, /.*#{host}.*/).to_raise(SocketError)
          expect(entity_matching_service.check_people_for_matches).to eq(error_data)
        end
      end
    end
  end
end
