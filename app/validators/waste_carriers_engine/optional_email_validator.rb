# frozen_string_literal: true

module WasteCarriersEngine
  class OptionalEmailValidator < ActiveModel::EachValidator

    def validate(record)
      return true unless record.contact_email.present?

      DefraRuby::Validators::EmailValidator.new(attributes: [:contact_email]).validate(record)
    end
  end
end
