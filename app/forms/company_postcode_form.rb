class CompanyPostcodeForm < BaseForm
  attr_accessor :business_type

  def initialize(transient_registration)
    super
    # We only use this for the correct microcopy
    self.business_type = @transient_registration.business_type
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    # TODO: Define allowed params, eg self.field = params[:field]
    # TODO: Include attributes to update in the attributes hash, eg { field: field }
    attributes = {}

    super(attributes, params[:reg_identifier])
  end
end
