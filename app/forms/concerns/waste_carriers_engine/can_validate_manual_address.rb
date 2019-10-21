# frozen_string_literal: true

module WasteCarriersEngine
  module CanValidateManualAddress
    extend ActiveSupport::Concern

    included do
      delegate :business_is_overseas?, to: :transient_registration

      validates :house_number, presence: true, length: { maximum: 200 }
      validates :address_line_1, presence: true, length: { maximum: 160 }
      validates :address_line_2, length: { maximum: 70 }
      validates :town_city, presence: true, length: { maximum: 30 }
      validates :postcode, length: { maximum: 30 }
      validates :country, presence: true, if: :business_is_overseas?
      validates :country, length: { maximum: 50 }
    end
  end
end
