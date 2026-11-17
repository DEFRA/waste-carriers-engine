# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Notify
    RSpec.describe NotifyClient do

      subject(:notify_client) { described_class.new(reference:, client:) }

      let(:registration) { create(:registration, :has_required_data) }
      let(:reference) { registration.reg_identifier }
      let(:client) { instance_double(Notifications::Client, send_email: nil, send_sms: nil, send_letter: nil) }

      before { allow(Notifications::Client).to receive(:new).and_return(client) }

      shared_examples "sends a reference" do |send_action, args|
        it do
          notify_client.send(send_action, args)
          aggregate_failures do
            expect(args).not_to include(:reference)
            expect(client).to have_received(send_action).with(hash_including(reference:))
          end
        end
      end

      context "with an email" do
        it_behaves_like "sends a reference", :send_email, { email_address: Faker::Internet.email }
      end

      context "with an sms" do
        it_behaves_like "sends a reference", :send_sms, { phone_number: Faker::PhoneNumber.phone_number }
      end

      context "with a letter" do
        it_behaves_like "sends a reference", :send_letter, { personalisation: {} }
      end
    end
  end
end
