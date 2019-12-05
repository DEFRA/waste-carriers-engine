# frozen_string_literal: true

module WasteCarriersEngine
  class FormsController < ApplicationController
    include ActionView::Helpers::UrlHelper

    before_action :authenticate_user!
    before_action :back_button_cache_buster
    before_action :validate_token

    # Expects a form class name (eg BusinessTypeForm) and a snake_case name for the form (eg business_type_form)
    def new(form_class, form)
      set_up_form(form_class, form, params[:token], true)
    end

    # Expects a form class name (eg BusinessTypeForm) and a snake_case name for the form (eg business_type_form)
    def create(form_class, form)
      return false unless set_up_form(form_class, form, params[:token])

      submit_form(instance_variable_get("@#{form}"), transient_registration_attributes)
    end

    def go_back
      find_or_initialize_transient_registration(params[:token])

      @transient_registration.back! if form_matches_state?
      redirect_to_correct_form
    end

    private

    def transient_registration_attributes
      # Default behavuour - permit no params
      # Override in subclasses when needed
      params.permit
    end

    def validate_token
      return redirect_to(page_path("invalid")) unless find_or_initialize_transient_registration(params[:token])
    end

    def find_or_initialize_transient_registration(token)
      @transient_registration ||= TransientRegistration.where(token: token).first
    end

    # Expects a form class name (eg BusinessTypeForm), a snake_case name for the form (eg business_type_form),
    # and the token param
    def set_up_form(form_class, form, token, get_request = false)
      find_or_initialize_transient_registration(token)

      set_workflow_state if get_request

      return false unless setup_checks_pass?

      # Set an instance variable for the form (eg. @business_type_form) using the provided class (eg. BusinessTypeForm)
      instance_variable_set("@#{form}", form_class.new(@transient_registration))
    end

    def submit_form(form, params)
      respond_to do |format|
        if form.submit(params)
          @transient_registration.next!
          format.html { redirect_to_correct_form }
          true
        else
          format.html { render :new }
          false
        end
      end
    end

    def redirect_to_correct_form
      redirect_to form_path
    end

    # Get the path based on the workflow state, with token as params, ie:
    # new_state_name_path/:token
    def form_path
      send("new_#{@transient_registration.workflow_state}_path".to_sym, @transient_registration.token)
    end

    def setup_checks_pass?
      transient_registration_is_valid? && user_has_permission? && can_be_renewed? && state_is_correct?
    end

    def set_workflow_state
      return unless state_can_navigate_flexibly?(@transient_registration.workflow_state)
      return unless state_can_navigate_flexibly?(requested_state)

      @transient_registration.update_attributes(workflow_state: requested_state)
    end

    def state_can_navigate_flexibly?(state)
      form_class = WasteCarriersEngine.const_get(state.camelize)
      form_class.can_navigate_flexibly?
    end

    def requested_state
      # Get the controller_name, excluding the last character (for example, changing location_forms to location_form)
      controller_name[0..-2]
    end

    # Guards

    def transient_registration_is_valid?
      return true if @transient_registration.valid?

      redirect_to page_path("invalid")
      false
    end

    def user_has_permission?
      return true if can? :update, @transient_registration

      redirect_to page_path("permission")
      false
    end

    def state_is_correct?
      return true if form_matches_state?

      redirect_to_correct_form
      false
    end

    def form_matches_state?
      controller_name == "#{@transient_registration.workflow_state}s"
    end

    def can_be_renewed?
      return true if @transient_registration.can_be_renewed?

      redirect_to page_path("unrenewable")
      false
    end

    # http://jacopretorius.net/2014/01/force-page-to-reload-on-browser-back-in-rails.html
    def back_button_cache_buster
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end
  end
end
