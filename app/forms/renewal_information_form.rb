class RenewalInformationForm < BaseForm
  # TODO: Define accessible attributes, eg attr_accessor :field
  attr_accessor :type_change, :total_fee

  def initialize(transient_registration)
    super
    self.type_change = @transient_registration.registration_type_changed?
    self.total_fee = @transient_registration.total_fee
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    # TODO: Define allowed params, eg self.field = params[:field]
    # TODO: Include attributes to update in the attributes hash, eg { field: field }
    attributes = {}

    super(attributes, params[:reg_identifier])
  end
end
