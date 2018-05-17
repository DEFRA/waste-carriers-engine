class TierCheckForm < BaseForm
  include CanNavigateFlexibly

  attr_accessor :temp_tier_check

  def initialize(transient_registration)
    super
    self.temp_tier_check = @transient_registration.temp_tier_check
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.temp_tier_check = convert_to_boolean(params[:temp_tier_check])
    attributes = { temp_tier_check: temp_tier_check }

    super(attributes, params[:reg_identifier])
  end

  validates :temp_tier_check, boolean: true
end
