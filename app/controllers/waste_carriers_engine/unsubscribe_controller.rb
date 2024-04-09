# frozen_string_literal: true

module WasteCarriersEngine
  class UnsubscribeController < ApplicationController

    include CanRecordCommunication

    def unsubscribe
      @registration = Registration.where(unsubscribe_token: params[:unsubscribe_token]).first
      if @registration
        @registration.update(communications_opted_in: false)
        create_communication_record

        redirect_to unsubscribe_successful_path
      else
        redirect_to unsubscribe_failed_path
      end
    end

    def unsubscribe_successful
      # This method is empty - defined so as to display the view
    end

    def unsubscribe_failed
      # This method is empty - defined so as to display the view
    end

    # Implement required methods for CanRecordCommunication:
    def template_id
      nil
    end

    def comms_label
      "User unsubscribed from email communication"
    end

    def notification_type
      "unsubscribed"
    end

    def recipient
      @registration.contact_email
    end
  end
end
