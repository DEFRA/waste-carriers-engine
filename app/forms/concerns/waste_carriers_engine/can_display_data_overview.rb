# frozen_string_literal: true

module WasteCarriersEngine
  module CanDisplayDataOverview
    extend ActiveSupport::Concern

    included do
      delegate :account_email, to: :transient_registration
      delegate :business_type, to: :transient_registration
      delegate :company_name, to: :transient_registration
      delegate :company_no, to: :transient_registration
      delegate :contact_address, to: :transient_registration
      delegate :contact_email, to: :transient_registration
      delegate :declared_convictions, to: :transient_registration
      delegate :first_name, to: :transient_registration
      delegate :last_name, to: :transient_registration
      delegate :location, to: :transient_registration
      delegate :main_people, to: :transient_registration
      delegate :phone_number, to: :transient_registration
      delegate :registered_address, to: :transient_registration
      delegate :registration_type, to: :transient_registration
      delegate :relevant_people, to: :transient_registration
      delegate :tier, to: :transient_registration
    end
  end
end
