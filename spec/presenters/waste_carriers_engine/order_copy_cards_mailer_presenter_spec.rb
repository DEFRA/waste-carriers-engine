# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe OrderCopyCardsMailerPresenter do
    subject { described_class.new(registration, order) }
    let(:registration) { double(:registration) }
    let(:order) { double(:order) }

    describe "#contact_name" do
      it "returns a string with first and last name" do
        expect(registration).to receive(:first_name).and_return("Bob")
        expect(registration).to receive(:last_name).and_return("Proctor")

        expect(subject.contact_name).to eq("Bob Proctor")
      end
    end

    describe "#total_cards" do
      it "returns the order item's quantity" do
        order_item = double(:order_item)
        result = double(:result)

        expect(order).to receive(:order_items).and_return([order_item])
        expect(order_item).to receive(:quantity).and_return(result)

        expect(subject.total_cards).to eq(result)
      end
    end

    describe "#order_description" do
      it "returns the order's description" do
        order_item = double(:order_item)
        result = double(:result)

        expect(order).to receive(:order_items).and_return([order_item])
        expect(order_item).to receive(:description).and_return(result)

        expect(subject.order_description).to eq(result)
      end
    end

    describe "#ordered_on_formatted_string" do
      it "returns the date the order was created as a string eg '31 October 2010'" do
        expect(order).to receive(:date_created).and_return(Time.parse("2010-10-31").to_datetime)

        expect(subject.ordered_on_formatted_string).to eq("31 October 2010")
      end
    end
  end
end
