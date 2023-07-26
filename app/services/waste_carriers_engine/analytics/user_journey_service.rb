# frozen_string_literal: true

module WasteCarriersEngine
  module Analytics
    class UserJourneyService < BaseService

      attr_accessor :transient_registration, :journey, :token, :current_user

      JOURNEY_TYPES = {
        "WasteCarriersEngine::NewRegistration" => "registration",
        "WasteCarriersEngine::RenewingRegistration" => "renewal"
      }.freeze

      def run(transient_registration:, current_user: nil)
        @transient_registration = transient_registration
        transient_registration_type = transient_registration.class.name
        journey_type = JOURNEY_TYPES[transient_registration_type]

        unless journey_type.present?
          Rails.logger.warn "Transient registration type #{transient_registration_type} " \
                            "unsupported for user journey analytics"
          return
        end

        page = transient_registration.workflow_state
        @token = transient_registration.token
        @current_user = current_user
        @journey = find_or_create_user_journey(journey_type, token)

        PageView.create!(page: page, time: Time.zone.now, route: route, user_journey: journey)

        if UserJourney::COMPLETION_PAGES.include?(page)
          journey.complete_journey(transient_registration)
        else
          journey.touch
        end
      end

      private

      def find_or_create_user_journey(journey_type, token)
        user_journey = UserJourney.where(token: token).first
        return user_journey if user_journey.present?

        UserJourney.create!(
          journey_type: journey_type,
          token: token,
          started_route: route,
          user: current_user&.email
        )
      end

      def pagename(request_path)
        request_path.split("/").last
      end

      def route
        @route ||= WasteCarriersEngine.configuration.host_is_back_office? ? "ASSISTED_DIGITAL" : "DIGITAL"
      end
    end
  end
end
