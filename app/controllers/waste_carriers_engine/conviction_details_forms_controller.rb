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
  end
end
