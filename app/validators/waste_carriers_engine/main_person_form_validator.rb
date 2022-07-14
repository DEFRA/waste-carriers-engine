# frozen_string_literal: true

module WasteCarriersEngine
  class MainPersonFormValidator < MainPersonValidator

    def validate(record)
      # Allow blank form submission if sufficient people already added
      return true if !record.fields_have_content? && record.enough_main_people?

      validate_individual_fields(record)
    end
  end
end
