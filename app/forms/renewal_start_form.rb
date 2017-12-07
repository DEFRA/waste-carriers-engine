class RenewalStartForm
  include ActiveModel::Model

  attr_accessor :regIdentifier

  def initialize(transient_registration)
    @transient_registration = transient_registration

    # Get values from transient registration so form will be pre-filled
    self.regIdentifier = @transient_registration.regIdentifier
  end

  def submit(params)
    # Define the params which are allowed
    self.regIdentifier = params[:regIdentifier]

    # Update the transient registration if valid
    if valid?
      @transient_registration.regIdentifier = regIdentifier
      @transient_registration.valid_new_renewal?

      params = @transient_registration.get_renewal_attributes
      @transient_registration.update(params)

      @transient_registration.save!
      true
    else
      false
    end
  end
end
