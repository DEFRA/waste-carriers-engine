class ContactPhoneForm < BaseForm
  attr_accessor :phone_number

  def initialize(transient_registration)
    super
    self.phone_number = @transient_registration.phone_number
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.phone_number = params[:phone_number]
    attributes = { phone_number: phone_number }

    super(attributes, params[:reg_identifier])
  end
end
