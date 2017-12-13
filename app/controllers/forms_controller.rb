class FormsController < ApplicationController
  include ActionView::Helpers::UrlHelper

  before_action :authenticate_user!

  # Expects a form class name (eg BusinessTypeForm) and a snake_case name for the form (eg business_type_form)
  def new(form_class, form)
    set_transient_registration(params[:reg_identifier])

    unless form_matches_state?
      redirect_to_correct_form
      return
    end

    # Set an instance variable for the form (eg. @business_type_form) using the provided class (eg. BusinessTypeForm)
    instance_variable_set("@#{form}", form_class.new(@transient_registration))
  end

  # Expects a form class name (eg BusinessTypeForm) and a snake_case name for the form (eg business_type_form)
  def create(form_class, form)
    set_transient_registration(params[form][:reg_identifier])

    unless form_matches_state?
      redirect_to_correct_form
      return
    end

    # Set an instance variable for the form (eg. @business_type_form) using the provided class (eg. BusinessTypeForm)
    instance_variable_set("@#{form}", form_class.new(@transient_registration))
    # Submit the form by getting the instance variable we just set
    submit_form(instance_variable_get("@#{form}"), params[form])
  end

  def go_back
    set_transient_registration(params[:reg_identifier])

    @transient_registration.back! if form_matches_state?
    redirect_to_correct_form
  end

  protected

  def set_transient_registration(reg_identifier)
    @transient_registration = if TransientRegistration.where(reg_identifier: reg_identifier).exists?
                                TransientRegistration.where(reg_identifier: reg_identifier).first
                              else
                                TransientRegistration.new(reg_identifier: reg_identifier)
                              end
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

  def form_matches_state?
    controller_name == "#{@transient_registration.workflow_state}s"
  end

  def redirect_to_correct_form
    redirect_to form_path
  end

  private

  # Get the path based on the workflow state, with reg_identifier as params, ie:
  # new_state_name_path/:reg_identifier
  def form_path
    send("new_#{@transient_registration.workflow_state}_path".to_sym, @transient_registration.reg_identifier)
  end
end
