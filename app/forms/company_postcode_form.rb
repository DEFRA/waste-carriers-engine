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
    attributes = { temp_postcode: temp_postcode }

    # While we won't proceed if the postcode isn't valid, we should always save it in case it's needed for manual entry
    @transient_registration.update_attributes(attributes)

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
