class PaymentSummaryForm < BaseForm
  attr_accessor :temp_payment_method, :type_change, :registration_cards, :registration_card_charge, :total_charge

  def initialize(transient_registration)
    super
    self.temp_payment_method = @transient_registration.temp_payment_method

    self.type_change = @transient_registration.registration_type_changed?
    self.registration_cards = @transient_registration.temp_cards || 0
    self.registration_card_charge = determine_total_card_charge
    self.total_charge = determine_total_charge
  end

  def submit(params)
    # Assign the params for validation and pass them to the BaseForm method for updating
    self.temp_payment_method = params[:temp_payment_method]
    attributes = { temp_payment_method: temp_payment_method }

    super(attributes, params[:reg_identifier])
  end

  validates :temp_payment_method, inclusion: { in: %w[card bank_transfer] }

  private

  def determine_total_charge
    charges = [Rails.configuration.renewal_charge]
    charges << Rails.configuration.type_change_charge if type_change
    charges << registration_card_charge
    charges.sum
  end

  def determine_total_card_charge
    registration_cards * Rails.configuration.card_charge
  end
end
