class ContactDetailsFormController < ApplicationController
  before_action :set_registration, only: %i[new create]

  def edit
    @contact_details_form = ContactDetailsForm.new(@registration)
  end

  def update
    @contact_details_form = ContactDetailsForm.new(@registration)
    if @contact_details_form.submit(params[:contact_details_form_form])
      format.html { redirect_to @registration, notice: "Registration was successfully updated." }
      format.json { render :show, status: :ok, location: @registration }
    else
      format.html { render :edit }
      format.json { render json: @registration.errors, status: :unprocessable_entity }
    end
  end

  private

  def set_registration
    @registration = Registration.find(params[:id])
  end

  def submit(params)
    # Define the params which are allowed
    self.firstName = params[:firstName]
    self.lastName = params[:lastName]
    self.phoneNumber = params[:phoneNumber]
    self.contactEmail = params[:contactEmail]
    # Update the registration if valid
    if valid?
      registration.firstName = firstName
      registration.lastName = lastName
      registration.phoneNumber = phoneNumber
      registration.contactEmail = contactEmail
      registration.save!
      true
    else
      false
    end
  end
end
