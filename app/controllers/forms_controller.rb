class FormsController < ApplicationController
  include ActionView::Helpers::UrlHelper

  before_action :authenticate_user!

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

  def form_path
    # Get the path based on the workflow state, with reg_identifier as params, ie:
    # new_state_name_path/:reg_identifier
    send("new_#{@transient_registration.workflow_state}_path".to_sym, @transient_registration.reg_identifier)
  end
end
