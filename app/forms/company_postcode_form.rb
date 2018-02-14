class CompanyPostcodeForm < BaseForm
  attr_accessor :business_type, :temp_postcode

  def initialize(transient_registration)
    super
    self.temp_postcode = @transient_registration.temp_postcode
    # We only use this for the correct microcopy
    self.business_type = @transient_registration.business_type
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.temp_postcode = params[:temp_postcode]
    format_postcode
    # TODO: Include attributes to update in the attributes hash, eg { field: field }
    attributes = { temp_postcode: temp_postcode }

    super(attributes, params[:reg_identifier])
  end

  validates_with TempPostcodeValidator

  private

  def format_postcode
    return unless temp_postcode.present?
    temp_postcode.upcase!
    temp_postcode.strip!
  end
end
