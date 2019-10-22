# frozen_string_literal: true

module WasteCarriersEngine
  class ConvictionDetailsFormsController < PersonFormsController
    def new
      super(ConvictionDetailsForm, "conviction_details_form")
    end

    def create
      super(ConvictionDetailsForm, "conviction_details_form")
    end

    def delete_person
      super(ConvictionDetailsForm, "conviction_details_form")
    end

    private

    def transient_registration_attributes
      params
        .fetch(:conviction_details_form, {})
        .permit(:first_name, :last_name, :position, :dob_day, :dob_month, :dob_year)
    end
  end
end
