# frozen_string_literal: true

require "rails_helper"

module Test
  OptionalEmailValidatable = Struct.new(:contact_email) do
    include ActiveModel::Validations

    attr_reader :contact_email

    validates_with WasteCarriersEngine::OptionalEmailValidator, attributes: [:contact_email]
  end
end

module WasteCarriersEngine
  RSpec.describe OptionalEmailValidator do

    subject(:validatable) { Test::OptionalEmailValidatable.new }

    before do
      allow(validatable).to receive(:contact_email).and_return(contact_email)
    end

    shared_examples "is valid" do
      it "passes the validity check" do
        expect(validatable).to be_valid
      end
    end

    shared_examples "is not valid" do
      it "does not pass the validity check" do
        expect(validatable).not_to be_valid
      end
    end

    context "with no contact email address" do
      let(:contact_email) { nil }

      it_behaves_like "is valid"
    end

    context "with a valid email address" do
      let(:contact_email) { Faker::Internet.email }

      it_behaves_like "is valid"
    end

    context "with an invalid email address" do
      let(:contact_email) { "not_a_valid_email" }

      it_behaves_like "is not valid"
    end
  end
end
