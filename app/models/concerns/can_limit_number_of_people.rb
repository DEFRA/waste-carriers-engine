module CanLimitNumberOfPeople
  extend ActiveSupport::Concern

  def enough_people?(type = person_type)
    return false if number_of_existing_people(type) < minimum_people(type)
    true
  end

  def can_only_have_one_person?(type = person_type)
    return false unless maximum_people(type)
    maximum_people(type) == 1
  end

  def maximum_people(type = person_type)
    case type
    when :key
      maximum_main_people
    when :relevant
      maximum_relevant_people
    end
  end

  def minimum_people(type = person_type)
    case type
    when :key
      minimum_main_people
    when :relevant
      minimum_relevant_people
    end
  end

  def number_of_existing_people(type = person_type)
    case type
    when :key
      @transient_registration.main_people.count
    when :relevant
      @transient_registration.relevant_people.count
    end
  end

  private

  # Main people

  def maximum_main_people
    return unless business_type.present?
    limits = main_people_limits.fetch(business_type.to_sym, nil)
    return unless limits.present?
    limits[:maximum]
  end

  def minimum_main_people
    # Business type should always be set, but use 1 as the default, just in case
    return 1 unless business_type.present?
    limits = main_people_limits.fetch(business_type.to_sym, nil)
    return 1 unless limits.present?
    limits[:minimum]
  end

  def main_people_limits
    {
      limitedCompany: { minimum: 1, maximum: nil },
      limitedLiabilityPartnership: { minimum: 1, maximum: nil },
      localAuthority: { minimum: 1, maximum: nil },
      overseas: { minimum: 1, maximum: nil },
      partnership: { minimum: 2, maximum: nil },
      soleTrader: { minimum: 1, maximum: 1 }
    }
  end

  # Relevant people

  def maximum_relevant_people
    nil
  end

  def minimum_relevant_people
    return 1 if @transient_registration.declared_convictions
    0
  end
end
