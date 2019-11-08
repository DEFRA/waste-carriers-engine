# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module ConvictionsCheck
    RSpec.describe PersonMatchService do
      describe "run" do
        let(:first_name) { "foo" }
        let(:last_name) { "bar" }
        let(:date_of_birth) { Date.today }

        let(:subject) do
          described_class.run(first_name: first_name,
                              last_name: last_name,
                              date_of_birth: date_of_birth)
        end

        it "does not explode" do
          expect { subject }.to_not raise_error
        end

        it "checks for matching entities" do
          expect(Entity).to receive(:matching_people).with(first_name: first_name,
                                                           last_name: last_name,
                                                           date_of_birth: date_of_birth)

          subject
        end
      end
    end
  end
end
