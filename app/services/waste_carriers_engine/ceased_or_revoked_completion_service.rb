# frozen_string_literal: true

module WasteCarriersEngine
  class CeasedOrRevokedCompletionService < BaseService
    attr_reader :transient_registration, :registration

    def run(transient_registration)
      @transient_registration = transient_registration
      @registration = transient_registration.registration

      merge_metadata
      destroy_transient_object
    end

    private

    def destroy_transient_object
      transient_registration.destroy
    end

    def merge_metadata
      registration.metaData.status = @transient_registration.metaData.status
      registration.metaData.revoked_reason = @transient_registration.metaData.revoked_reason

      registration.save!
    end
  end
end
