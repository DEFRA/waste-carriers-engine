class FormsController < ApplicationController
  include ActionView::Helpers::UrlHelper

  before_action :authenticate_user!

  # Expects a form class name (eg BusinessTypeForm) and a snake_case name for the form (eg business_type_form)
  def new(form_class, form)
    set_up_form(form_class, form, params[:reg_identifier])
  end

  # Expects a form class name (eg BusinessTypeForm) and a snake_case name for the form (eg business_type_form)
  def create(form_class, form)
    return unless set_up_form(form_class, form, params[form][:reg_identifier])

    # Submit the form by getting the instance variable we just set
    submit_form(instance_variable_get("@#{form}"), params[form])
  end

  def go_back
    set_transient_registration(params[:reg_identifier])

    @transient_registration.back! if form_matches_state?
    redirect_to_correct_form
  end

  private

  # Expects a form class name (eg BusinessTypeForm), a snake_case name for the form (eg business_type_form),
  # and the reg_identifier param
  def set_up_form(form_class, form, reg_identifier)
    set_transient_registration(reg_identifier)

    unless @transient_registration.valid?
      redirect_to page_path("errors/invalid")
      return false
    end

    unless user_has_permission?
      redirect_to page_path("errors/permission")
      return false
    end

    unless form_matches_state?
      redirect_to_correct_form
      return false
    end

    # Set an instance variable for the form (eg. @business_type_form) using the provided class (eg. BusinessTypeForm)
    instance_variable_set("@#{form}", form_class.new(@transient_registration))
  end

  def user_has_permission?
    can? :update, @transient_registration
  end

  def set_transient_registration(reg_identifier)
    @transient_registration = TransientRegistration.where(reg_identifier: reg_identifier).first ||
                              TransientRegistration.new(reg_identifier: reg_identifier)
  end

  def form_matches_state?
    controller_name == "#{@transient_registration.workflow_state}s"
  end

  def redirect_to_correct_form
    redirect_to form_path
  end

  # Get the path based on the workflow state, with reg_identifier as params, ie:
  # new_state_name_path/:reg_identifier
  def form_path
    send("new_#{@transient_registration.workflow_state}_path".to_sym, @transient_registration.reg_identifier)
  end

  def submit_form(form, params)
    respond_to do |format|
      if form.submit(params)
        @transient_registration.next!
        format.html { redirect_to_correct_form }
      else
        format.html { render :new }
      end
    end
  end
end
