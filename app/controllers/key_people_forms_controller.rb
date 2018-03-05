class KeyPeopleFormsController < FormsController
  def new
    super(KeyPeopleForm, "key_people_form")
  end

  def create
    if params[:commit] == I18n.t("key_people_forms.new.add_person_link")
      submit_and_add_another
    else
      super(KeyPeopleForm, "key_people_form")
    end
  end

  def submit_and_add_another
    return unless set_up_form(KeyPeopleForm, "key_people_form", params["key_people_form"][:reg_identifier])

    respond_to do |format|
      if @key_people_form.submit(params["key_people_form"])
        format.html { redirect_to_correct_form }
      else
        format.html { render :new }
      end
    end
  end
end
