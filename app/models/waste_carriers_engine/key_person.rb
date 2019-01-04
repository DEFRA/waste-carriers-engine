# frozen_string_literal: true

module WasteCarriersEngine
  class KeyPerson
    include Mongoid::Document

    embedded_in :registration,            class_name: "WasteCarriersEngine::Registration"
    embedded_in :past_registration,       class_name: "WasteCarriersEngine::PastRegistration"
    embeds_one :conviction_search_result, class_name: "WasteCarriersEngine::ConvictionSearchResult"

    accepts_nested_attributes_for :conviction_search_result

    after_initialize :set_date_of_birth

    field :first_name,  type: String
    field :last_name,   type: String
    field :position,    type: String
    field :dob_day,     type: Integer
    field :dob_month,   type: Integer
    field :dob_year,    type: Integer
    field :dob,         type: DateTime
    field :person_type, type: String

    def conviction_check_required?
      return false unless conviction_search_result.present?
      return false if conviction_search_result.match_result == "NO"

      true
    end

    private

    def set_date_of_birth
      self.dob = Date.new(dob_year, dob_month, dob_day)
    rescue NoMethodError
      errors.add(:dob, :invalid_date)
    rescue ArgumentError
      errors.add(:dob, :invalid_date)
    rescue TypeError
      errors.add(:dob, :invalid_date)
    end
  end
end
