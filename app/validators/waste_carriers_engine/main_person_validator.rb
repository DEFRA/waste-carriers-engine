# frozen_string_literal: true

module WasteCarriersEngine
  class MainPersonValidator < PersonValidator
    private

    def validate_number_of_people(record)
      return if record.enough_main_people?

      record.errors.add(:base, :not_enough_main_people, count: record.minimum_main_people)
    end
  end
end
