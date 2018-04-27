class PaymentSummaryForm < BaseForm
  attr_accessor :temp_payment_method, :type_change, :registration_cards, :registration_card_charge, :total_charge

  def initialize(transient_registration)
    super
    self.temp_payment_method = @transient_registration.temp_payment_method

    self.type_change = @transient_registration.registration_type_changed?
    self.registration_cards = @transient_registration.temp_cards || 0
    self.registration_card_charge = @transient_registration.total_registration_card_charge
    self.total_charge = @transient_registration.total_to_pay
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.temp_payment_method = params[:temp_payment_method]
    attributes = { temp_payment_method: temp_payment_method }

    super(attributes, params[:reg_identifier])
  end

  validates :temp_payment_method, inclusion: { in: %w[card bank_transfer] }
end
