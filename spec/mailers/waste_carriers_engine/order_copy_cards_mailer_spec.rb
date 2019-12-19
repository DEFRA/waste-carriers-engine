# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe OrderCopyCardsMailer do
    before do
      allow(Rails.configuration).to receive(:email_service_email).and_return("test@example.com")
    end

    describe ".send_order_completed_email" do
      let(:registration) { create(:registration, :has_required_data, :has_copy_cards_order) }
      let(:order) { registration.finance_details.orders.last }

      let(:mail) { OrderCopyCardsMailer.send_order_completed_email(registration, order) }

      it "send an email using the correct information" do
        expect(mail.from).to eq(["test@example.com"])

        expect(mail.subject).to eq("We’re printing your waste carriers registration cards")

        expect(mail.body.encoded).to include(registration.reg_identifier)
      end
    end

    describe ".send_awaiting_payment_email" do
      let(:registration) { create(:registration, :has_required_data, :has_copy_cards_order) }
      let(:order) { registration.finance_details.orders.last }

      let(:mail) { OrderCopyCardsMailer.send_awaiting_payment_email(registration, order) }

      it "send an email using the correct information" do
        expect(mail.from).to eq(["test@example.com"])

        expect(mail.subject).to eq("You need to pay for your waste carriers registration card order")

        expect(mail.body.encoded).to include(registration.reg_identifier)
      end
    end
  end
end
