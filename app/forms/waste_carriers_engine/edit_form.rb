# frozen_string_literal: true

module WasteCarriersEngine
  class EditForm < BaseForm
    delegate :reg_identifier, to: :transient_registration

    after_initialize :persist_registration

    private

    def persist_registration
      transient_registration.save! unless transient_registration.persisted?
    end
  end
end
