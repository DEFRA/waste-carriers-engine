# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe DiscernUkNumberTypeService, type: :service do
    subject(:result) { described_class.run(phone_number: phone_number) }

    context "when the phone number is a mobile number" do
      let(:phone_number) { "07555111222" }

      it "returns 'mobile'" do
        expect(result).to eq("mobile")
      end

      context "when the number contains spaces" do
        let(:phone_number) { "07 555 111 222" }

        it "returns 'mobile'" do
          expect(result).to eq("mobile")
        end
      end

      context "when the number has a country code" do
        let(:phone_number) { "+447555111222" }

        it "returns 'mobile'" do
          expect(result).to eq("mobile")
        end
      end

      context "when the number has a country code and contains spaces" do
        let(:phone_number) { "+44 7555 111 222" }

        it "returns 'mobile'" do
          expect(result).to eq("mobile")
        end
      end
    end

    context "when the phone number is a landline number" do
      let(:phone_number) { "01234567890" }

      it "returns 'landline'" do
        expect(result).to eq("landline")
      end

      context "when the number contains spaces" do
        let(:phone_number) { "0123 456 7890" }

        it "returns 'landline'" do
          expect(result).to eq("landline")
        end
      end

      context "when the number has a country code" do
        let(:phone_number) { "+441234567890" }

        it "returns 'landline'" do
          expect(result).to eq("landline")
        end
      end

      context "when the number has a country code and contains spaces" do
        let(:phone_number) { "+44 1234 567 890" }

        it "returns 'landline'" do
          expect(result).to eq("landline")
        end
      end
    end

    context "when the phone number does not match mobile or landline formats" do
      let(:phone_number) { "05001112222" }

      it "returns 'unknown'" do
        expect(result).to eq("unknown")
      end
    end
  end
end
