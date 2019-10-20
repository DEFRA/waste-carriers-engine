# frozen_string_literal: true

module WasteCarriersEngine
  module CanCheckRegistrationStatus
    extend ActiveSupport::Concern

    included do
      def active?
        metaData.ACTIVE?
      end

      def expired?
        metaData.EXPIRED?
      end

      def pending?
        metaData.PENDING?
      end

      def refused?
        metaData.REFUSED?
      end

      def revoked?
        metaData.REVOKED?
      end
    end
  end
end
