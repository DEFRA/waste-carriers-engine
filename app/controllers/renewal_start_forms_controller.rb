class RenewalStartFormsController < ApplicationController
  before_action :authenticate_user!

  def new
    set_transient_registration(params[:reg_identifier])
    @transient_registration.valid_new_renewal?
    @renewal_start_form = RenewalStartForm.new(@transient_registration)
  end

  def create
    set_transient_registration(params[:renewal_start_form][:id])
    @renewal_start_form = RenewalStartForm.new(@transient_registration)

    respond_to do |format|
      if @renewal_start_form.submit(params[:renewal_start_form])
        format.html { redirect_to @transient_registration, notice: "Transient registration was successfully updated." }
        format.json { render :show, status: :ok, location: @transient_registration }
      else
        format.html { render :new }
        format.json { render json: @transient_registration.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_transient_registration(reg_identifier)
    if TransientRegistration.where(regIdentifier: reg_identifier).exists?
      @transient_registration = TransientRegistration.find(regIdentifier: reg_identifier)
    else
      @transient_registration = TransientRegistration.new(regIdentifier: reg_identifier)
    end
  end
end
