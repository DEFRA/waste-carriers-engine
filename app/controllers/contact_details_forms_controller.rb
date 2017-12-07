class ContactDetailsFormsController < ApplicationController
  before_action :authenticate_user!

  def new
    @registration = Registration.find(params[:id])
    @contact_details_form = ContactDetailsForm.new(@registration)
  end

  def create
    @registration = Registration.find(params[:contact_details_form][:id])
    @contact_details_form = ContactDetailsForm.new(@registration)

    respond_to do |format|
      if @contact_details_form.submit(params[:contact_details_form])
        format.html { redirect_to @registration, notice: "Registration was successfully updated." }
        format.json { render :show, status: :ok, location: @registration }
      else
        format.html { render :new }
        format.json { render json: @registration.errors, status: :unprocessable_entity }
      end
    end
  end
end
