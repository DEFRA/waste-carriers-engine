class CardsForm < BaseForm
  attr_accessor :temp_cards

  def initialize(transient_registration)
    super
    self.temp_cards = 0
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    # TODO: Define allowed params, eg self.field = params[:field]
    # TODO: Include attributes to update in the attributes hash, eg { field: field }
    attributes = {}

    super(attributes, params[:reg_identifier])
  end
end
