require "rails_helper"

RSpec.describe WorldpayService do
  let(:transient_registration) do
    create(:transient_registration,
           :has_required_data,
           :has_overseas_addresses,
           :has_finance_details,
           temp_cards: 0)
  end
  let(:order) { transient_registration[:financeDetails][:orders].first }
  let(:worldpay_service) { WorldpayService.new(transient_registration, order) }

  describe "set_up_payment_link" do
    it "returns a link" do
      VCR.use_cassette("worldpay_initial_request") do
        link = "https://secure-test.worldpay.com/wcc/dispatcher?OrderKey="
        expect(worldpay_service.set_up_payment_link).to include(link)
      end
    end

    context "when the request is invalid" do
      before do
        allow_any_instance_of(WorldpayXmlService).to receive(:build_xml).and_return("foo")
      end

      it "returns :error" do
        VCR.use_cassette("worldpay_initial_request_invalid") do
          expect(worldpay_service.set_up_payment_link).to eq(:error)
        end
      end
    end
  end
end
