# frozen_string_literal: true

module WasteCarriersEngine
  module Analytics
    class UserJourneyService < BaseService

      attr_accessor :transient_registration, :journey, :token, :current_user

      def run(transient_registration:, current_user: nil)
        @transient_registration = transient_registration
        journey_type = journey_type_from_registration_class

        page = transient_registration.workflow_state
        @token = transient_registration.token
        @current_user = current_user
        @journey = find_or_create_user_journey(journey_type, token)

        # Log consecutive views of the same page once only
        return if @journey.page_views.last.present? && @journey.page_views.last.page == page

        journey.page_views.create!(page:, route:, time: Time.zone.now)

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

        user_journey = UserJourney.create!(
          journey_type: journey_type,
          token: token,
          started_route: route,
          user: current_user&.email
        )

        # start form does not get added automatically as the transient_registration token has not yet been added
        user_journey.page_views.create(page: start_page_name,
                                       route:,
                                       time: transient_registration.metaData&.last_modified || Time.zone.now)

        user_journey
      end

      def journey_type_from_registration_class
        transient_registration.class.to_s.split("::").last
      end

      def start_page_name
        transient_registration.is_a?(RenewingRegistration) ? "renewal_start_form" : "start_form"
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
