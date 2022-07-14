# frozen_string_literal: true

module WasteCarriersEngine
  class RelevantPersonFormValidator < RelevantPersonValidator

    def validate(record)
      # Allow blank form submission if sufficient people already added
      return true if !record.fields_have_content? && record.enough_relevant_people?

      validate_individual_fields(record)
    end
  end
end
