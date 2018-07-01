module WasteCarriersEngine
  class CardsForm < BaseForm
    attr_accessor :temp_cards

    def initialize(transient_registration)
      super
      self.temp_cards = @transient_registration.temp_cards || 0
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.temp_cards = params[:temp_cards]
      attributes = { temp_cards: temp_cards }

      super(attributes, params[:reg_identifier])
    end

    # Must be a positive integer or 0
    # Leaving it blank is also valid - this will automatically sub in a 0 since the field is marked as an Integer
    validates :temp_cards, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
                           allow_blank: true
  end
end
