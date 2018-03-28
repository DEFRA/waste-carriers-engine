class ConvictionDetailsFormsController < FormsController
  def new
    super(ConvictionDetailsForm, "conviction_details_form")
  end

  def create
    if params[:commit] == I18n.t("conviction_details_forms.new.add_person_link")
      submit_and_add_another
    else
      super(ConvictionDetailsForm, "conviction_details_form")
    end
  end

  def submit_and_add_another
    return unless set_up_form(ConvictionDetailsForm, "conviction_details_form", params["conviction_details_form"][:reg_identifier])

    respond_to do |format|
      if @conviction_details_form.submit(params["conviction_details_form"])
        format.html { redirect_to_correct_form }
      else
        format.html { render :new }
      end
    end
  end

  def delete_person
    return unless set_up_form(ConvictionDetailsForm, "conviction_details_form", params[:reg_identifier])

    respond_to do |format|
      # Check if there are any matches first, to avoid a Mongoid error
      people_with_id = @transient_registration.keyPeople.where(id: params[:id])
      people_with_id.first.delete if people_with_id.any?

      format.html { redirect_to_correct_form }
    end
  end
end
