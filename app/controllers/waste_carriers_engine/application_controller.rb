# frozen_string_literal: true

module WasteCarriersEngine
  class ApplicationController < ActionController::Base
    include WasteCarriersEngine::CanAddDebugLogging

    # Tag all log rows with the controller and action name if detailed logging enabled
    around_action :tag_logs

    # Collect analytics data
    after_action :record_user_journey

    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    # Use the host application's default layout
    layout "application"

    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    rescue_from StandardError do |e|
      Airbrake.notify e
      Rails.logger.error "Unhandled exception: #{e}\n#{e.backtrace}"
      log_transient_registration_details("Uncaught system error", e, @transient_registration)
      redirect_to page_path("system_error")
    end

    def current_user
      return unless defined?(super)

      # :nocov:
      super
      # :nocov:
    end

    protected

    # Wrap the yield in a TaggedLogging block to identify controller and action in logs
    def tag_logs
      Rails.logger.tagged(self.class.name, self.action_name) do
        yield
      end
    end

    def record_user_journey
      return unless @transient_registration.present? && @transient_registration.token.present?

      WasteCarriersEngine::Analytics::UserJourneyService.run(
        transient_registration: @transient_registration,
        current_user: current_user
      )
    end
  end
end
