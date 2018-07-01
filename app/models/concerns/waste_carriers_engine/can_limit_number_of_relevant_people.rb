module WasteCarriersEngine
  module CanLimitNumberOfRelevantPeople
    extend ActiveSupport::Concern

    def enough_relevant_people?
      return false if number_of_existing_relevant_people < minimum_relevant_people
      true
    end

    def minimum_relevant_people
      return 1 if @transient_registration.declared_convictions
      0
    end

    def number_of_existing_relevant_people
      @transient_registration.relevant_people.count
    end
  end
end
