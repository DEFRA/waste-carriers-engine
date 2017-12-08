class RenewalStartFormsController < ApplicationController
  before_action :authenticate_user!

  def new
    set_transient_registration(params[:reg_identifier])
    @renewal_start_form = RenewalStartForm.new(@transient_registration)
    # Run validations now so we know if the registration exists and can be renewed
    @renewal_start_form.validate
  end

  def create
    set_transient_registration(params[:renewal_start_form][:id])
    @renewal_start_form = RenewalStartForm.new(@transient_registration)

    respond_to do |format|
      if @renewal_start_form.submit(params[:renewal_start_form])
        format.html { redirect_to root_path, notice: "Transient registration was successfully updated." }
        format.json { render :show, status: :ok, location: @transient_registration }
      else
        format.html { render :new }
        format.json { render json: @transient_registration.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_transient_registration(reg_identifier)
    @transient_registration = if TransientRegistration.where(reg_identifier: reg_identifier).exists?
                                TransientRegistration.where(reg_identifier: reg_identifier).first
                              else
                                TransientRegistration.new(reg_identifier: reg_identifier)
                              end
  end
end
