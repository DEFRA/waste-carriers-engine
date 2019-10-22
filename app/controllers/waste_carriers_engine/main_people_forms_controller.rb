# frozen_string_literal: true

module WasteCarriersEngine
  class MainPeopleFormsController < PersonFormsController
    def new
      super(MainPeopleForm, "main_people_form")
    end

    def create
      super(MainPeopleForm, "main_people_form")
    end

    def delete_person
      super(MainPeopleForm, "main_people_form")
    end

    private

    def transient_registration_attributes
      params
        .fetch(:main_people_form, {})
        .permit(:first_name, :last_name, :position, :dob_day, :dob_month, :dob_year)
    end
  end
end
