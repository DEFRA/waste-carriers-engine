module WasteCarriersEngine
  class KeyPeopleValidator < ActiveModel::Validator
    def validate(record)
      validate_main_people(record)
      validate_relevant_people(record)
    end

    private

    def validate_main_people(record)
      return false unless valid_number_of_main_people?(record)
      return true unless record.main_people.present? && record.main_people.count.positive?
      valid_individual_main_people?(record)
    end

    def validate_relevant_people(record)
      return false unless valid_number_of_relevant_people?(record)
      return true unless record.relevant_people.present? && record.relevant_people.count.positive?
      valid_individual_relevant_people?(record)
    end

    def valid_number_of_main_people?(record)
      return true if record.enough_main_people?
      record.errors.add(:base, :not_enough_main_people, count: record.minimum_main_people)
      false
    end

    def valid_number_of_relevant_people?(record)
      return true if record.enough_relevant_people?
      record.errors.add(:base, :not_enough_relevant_people, count: record.minimum_relevant_people)
      false
    end

    def valid_individual_main_people?(record)
      valid = true
      record.main_people.each do |person|
        next if valid_main_person?(person)
        record.errors.add(:base, :invalid_main_person)
        valid = false
      end
      valid
    end

    def valid_individual_relevant_people?(record)
      valid = true
      record.relevant_people.each do |person|
        next if valid_relevant_person?(person)
        record.errors.add(:base, :invalid_relevant_person)
        valid = false
      end
      valid
    end

    def valid_main_person?(person)
      MainPersonValidator.new(validate_fields: true).validate(person)
      !person.errors.present?
    end

    def valid_relevant_person?(person)
      RelevantPersonValidator.new(validate_fields: true).validate(person)
      !person.errors.present?
    end
  end
end
