class ContactEmailForm < BaseForm
  # TODO: Define accessible attributes, eg attr_accessor :field

  def initialize(transient_registration)
    super
    # TODO: Define params to get from transient_registration, eg self.field = @transient_registration.field
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    # TODO: Define allowed params, eg self.field = params[:field]
    # TODO: Include attributes to update in the attributes hash, eg { field: field }
    attributes = {}

    super(attributes, params[:reg_identifier])
  end
end
