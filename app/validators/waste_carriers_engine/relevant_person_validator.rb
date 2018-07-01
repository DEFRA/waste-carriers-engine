module WasteCarriersEngine
  class RelevantPersonValidator < PersonValidator
    private

    def validate_number_of_people(record)
      return if record.enough_relevant_people?
      record.errors.add(:base, :not_enough_relevant_people, count: record.minimum_relevant_people)
    end
  end
end
