# frozen_string_literal: true

module WasteCarriersEngine
  module CanMergeFinanceDetails
    extend ActiveSupport::Concern

    def merge_finance_details
      initialize_finance_details(registration)
      initialize_finance_details(transient_registration)

      # To avoid issues which arose during the Rails 7 upgrade, where direct iteration over
      # `transient_registration.finance_details.payments` and `transient_registration.finance_details.orders`
      # didn't iterate over every payment or order respectively, we first collect all payments and orders
      # into temporary arrays. This ensures that each payment and each order are iterated over without interference,
      # as a payment can belong to only one payments collection at a time, and similarly for orders.
      # This cannot be done using a clone as that changes the ids.

      transient_orders_array = []
      transient_registration.finance_details.orders.each do |order|
        transient_orders_array << order
      end

      transient_orders_array.each do |order|
        registration.finance_details.orders << order
      end

      transient_payments_array = []
      transient_registration.finance_details.payments.each do |payment|
        transient_payments_array << payment
      end

      transient_payments_array.each do |payment|
        registration.finance_details.payments << payment
      end

      registration.finance_details.update_balance
    end

    # If for some reason we have no existing finance info, create empty objects
    def initialize_finance_details(registration)
      registration.finance_details = FinanceDetails.new unless registration.finance_details.present?
      initialize_orders(registration)
      initialize_payments(registration)
    end

    def initialize_orders(registration)
      registration.finance_details.orders = [] unless registration.finance_details.orders.present?
    end

    def initialize_payments(registration)
      registration.finance_details.payments = [] unless registration.finance_details.payments.present?
    end
  end
end
