# frozen_string_literal: true

require "rails_helper"

module Test
  ContactEmailValidatable = Struct.new(:contact_email) do
    include ActiveModel::Validations

    attr_reader :contact_email
    attr_reader :confirmed_email
    attr_reader :no_contact_email

    validates_with WasteCarriersEngine::ContactEmailValidator, attributes: [:contact_email]
  end
end

module WasteCarriersEngine
  RSpec.describe ContactEmailValidator do

    subject { Test::ContactEmailValidatable.new }

    let(:contact_email) { Faker::Internet.email }
    let(:confirmed_email) { contact_email }
    before do
      allow(subject).to receive(:contact_email).and_return(contact_email)
      allow(subject).to receive(:confirmed_email).and_return(confirmed_email)
      allow(subject).to receive(:no_contact_email).and_return(no_contact_email)
    end

    shared_examples "is valid" do
      it "passes the validity check" do
        expect(subject).to be_valid
      end
    end

    shared_examples "is not valid" do
      it "does not pass the validity check" do
        expect(subject).not_to be_valid
      end
    end

    RSpec.shared_examples "contact email address is required" do
      context "with an email address" do
        let(:contact_email) { Faker::Internet.email }
        it_behaves_like "is valid"
      end

      context "without an email address" do
        let(:contact_email) { nil }
        it_behaves_like "is not valid"
      end

      context "with a matching confirmed email address" do
        let(:confirmed_email) { contact_email }
        it_behaves_like "is valid"
      end

      context "with a mismatched confirmed email address" do
        let(:confirmed_email) { "not@chance.com" }
        it_behaves_like "is not valid"
      end
    end

    context "when running in the front office" do
      before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(false) }
      let(:no_contact_email) { nil }

      it_behaves_like "contact email address is required"
    end

    context "when running in the back office" do
      before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(true) }

      context "with no_contact_email set to zero" do
        let(:no_contact_email) { "0" }
        it_behaves_like "contact email address is required"
      end

      context "with no_contact_email set to nil" do
        let(:no_contact_email) { nil }
        it_behaves_like "contact email address is required"
      end

      context "with no_contact_email set to one" do
        let(:no_contact_email) { "1" }

        context "with an email address" do
          let(:contact_email) { Faker::Internet.email }
          it_behaves_like "is not valid"
        end

        context "without an email address" do
          let(:contact_email) { nil }
          it_behaves_like "is valid"
        end
      end
    end
  end
end
