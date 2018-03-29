class PersonFormsController < FormsController
  def create(form_class, form)
    if params[:commit] == I18n.t("#{form}s.new.add_person_link")
      submit_and_add_another(form_class, form)
    else
      super(form_class, form)
    end
  end

  def submit_and_add_another(form_class, form)
    return unless set_up_form(form_class, form, params[form][:reg_identifier])

    form_instance_variable = instance_variable_get("@#{form}")

    respond_to do |format|
      if form_instance_variable.submit(params[form])
        format.html { redirect_to_correct_form }
      else
        format.html { render :new }
      end
    end
  end

  def delete_person(form_class, form)
    return unless set_up_form(form_class, form, params[:reg_identifier])

    respond_to do |format|
      # Check if there are any matches first, to avoid a Mongoid error
      people_with_id = @transient_registration.keyPeople.where(id: params[:id])
      people_with_id.first.delete if people_with_id.any?

      format.html { redirect_to_correct_form }
    end
  end
end
