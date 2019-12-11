# frozen_string_literal: true

module WasteCarriersEngine
  module CanMergeFinanceDetails
    extend ActiveSupport::Concern

    def merge_finance_details
      initialize_finance_details(registration)
      initialize_finance_details(transient_registration)

      transient_registration.finance_details.orders.each do |order|
        registration.finance_details.orders << order
      end

      transient_registration.finance_details.payments.each do |payment|
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
