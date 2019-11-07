# frozen_string_literal: true

module WasteCarriersEngine
  module ConvictionsCheck
    class Entity
      include Mongoid::Document

      store_in collection: "entities"

      # The full name, either of an organisation or an individual
      field :name,                                 type: String
      # Only used for individuals - may not be known or available
      field :dateOfBirth, as: :date_of_birth,      type: Date
      # Only used for organisations, if applicable
      field :companyNumber, as: :company_number,   type: String
      # The system where the match is from
      field :systemFlag, as: :system_flag,         type: String
      # The incident number or reference code
      field :incidentNumber, as: :incident_number, type: String
    end
  end
end
