# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module ConvictionsCheck
    RSpec.describe Entity, type: :model do
      describe "public interface" do
        properties = %i[name date_of_birth company_number system_flag incident_number]

        properties.each do |property|
          it "responds to property" do
            expect(subject).to respond_to(property)
          end
        end
      end
    end
  end
end
