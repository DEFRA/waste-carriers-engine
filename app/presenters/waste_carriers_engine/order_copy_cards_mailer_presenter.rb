# frozen_string_literal: true

module WasteCarriersEngine
  class OrderCopyCardsMailerPresenter < BasePresenter
    def initialize(registration, copy_cards_order, view_context=nil)
      @copy_cards_order = copy_cards_order

      super(registration, view_context)
    end

    def contact_name
      @_contact_name ||= "#{first_name} #{last_name}"
    end

    def order_description
      @_cards_count ||= copy_cards_order.order_items.first.description
    end

    def ordered_on_formatted_string
      @_ordered_on ||= copy_cards_order.date_created.to_datetime.to_formatted_s(:day_month_year)
    end

    def total_paid
      @_total_paid ||= copy_cards_order.total_amount
    end

    private

    attr_reader :copy_cards_order
  end
end
