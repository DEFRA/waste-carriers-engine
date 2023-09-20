# frozen_string_literal: true

module WasteCarriersEngine
  class MergeFinanceDetailsService
    def self.call(registration:, transient_registration:)
      new(registration: registration, transient_registration: transient_registration).send(:merge_finance_details)
    end

    private

    attr_reader :registration, :transient_registration

    def initialize(registration:, transient_registration:)
      @registration = registration
      @transient_registration = transient_registration
      initialize_finance_details(@registration)
      initialize_finance_details(@transient_registration)
    end

    def merge_finance_details
      merge_orders
      merge_payments

      registration.finance_details.update_balance
    end

    def merge_orders
      # To avoid issues which arose during the Rails 7 upgrade, where direct iteration over
      # `transient_registration.finance_details.orders` didn't iterate over every order respectively,
      # we first collect all orders into a temporary array. This ensures that each order is iterated over
      # without interference, as an order can belong to only one orders collection at a time.
      # This cannot be done using a clone as that changes the ids.
      transient_orders_array = transient_registration.finance_details.orders.to_a

      transient_orders_array.each do |order|
        registration.finance_details.orders << order
      end
    end

    def merge_payments
      # Similarly, to avoid issues which arose during the Rails 7 upgrade, where direct iteration over
      # `transient_registration.finance_details.payments` didn't iterate over every payment respectively,
      # we first collect all payments into a temporary array. This ensures that each payment is iterated over
      # without interference, as a payment can belong to only one payments collection at a time.
      # This cannot be done using a clone as that changes the ids.
      transient_payments_array = transient_registration.finance_details.payments.to_a

      transient_payments_array.each do |payment|
        registration.finance_details.payments << payment
      end
    end

    def initialize_finance_details(registration)
      registration.finance_details ||= FinanceDetails.new
      initialize_orders(registration)
      initialize_payments(registration)
    end

    def initialize_orders(registration)
      registration.finance_details.orders ||= []
    end

    def initialize_payments(registration)
      registration.finance_details.payments ||= []
    end
  end
end
