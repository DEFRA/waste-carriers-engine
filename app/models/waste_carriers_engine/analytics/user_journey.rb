# frozen_string_literal: true

module WasteCarriersEngine
  module Analytics
    class UserJourney
      include Mongoid::Document
      include Mongoid::Timestamps

      store_in collection: "analytics_user_journeys"

      has_many :page_views, dependent: :destroy

      validates :journey_type, inclusion: { in: %w[registration renewal] }
      validates :started_route, inclusion: { in: %w[DIGITAL ASSISTED_DIGITAL] }
      validates :token, presence: true

      COMPLETION_PAGES = %w[
        registration_completed_form
        renewal_complete_form
      ].freeze

      field :journey_type, type: String
      field :started_at, type: DateTime
      field :completed_at, type: DateTime
      field :token, type: String
      field :user, type: String
      field :started_route, type: String
      field :completed_route, type: String
      field :registration_data, type: Hash

      scope :registrations, -> { where(journey_type: "registration") }
      scope :renewals, -> { where(journey_type: "renewal") }
      scope :started_digital, -> { where(started_route: "DIGITAL") }
      scope :started_assisted_digital, -> { where(started_route: "ASSISTED_DIGITAL") }
      scope :incomplete, -> { where(completed_at: nil) }
      scope :completed, -> { where.not(completed_at: nil) }
      scope :completed_digital, -> { where(completed_route: "DIGITAL") }
      scope :completed_assisted_digital, -> { where(completed_route: "ASSISTED_DIGITAL") }
      scope :date_range, lambda { |start_date, end_date|
        where(:started_at.gte => start_date.midnight, :started_at.lt => end_date.midnight + 1)
      }

      def complete_journey(transient_registration)
        route = WasteCarriersEngine.configuration.host_is_back_office? ? "ASSISTED_DIGITAL" : "DIGITAL"
        update(completed_at: Time.zone.now)
        update(completed_route: route)
        update(registration_data: transient_registration.attributes.slice(
          :businessType,
          :declaredConvictions,
          :registrationType
        ))
      end

      def self.average_duration(user_journey_scope)
        in_scope_completed = user_journey_scope.where.not(completed_at: nil)
        in_scope_completed_total = in_scope_completed.sum { |uj| uj.completed_at.to_time - uj.created_at.to_time }
        in_scope_completed_count = in_scope_completed.count

        in_scope_incomplete = user_journey_scope.where(completed_at: nil)
        in_scope_incomplete_total = in_scope_incomplete.sum { |uj| uj.updated_at.to_time - uj.created_at.to_time }
        in_scope_incomplete_count = in_scope_incomplete.count

        total_count = in_scope_completed_count + in_scope_incomplete_count
        return 0 unless total_count.positive?

        (in_scope_completed_total + in_scope_incomplete_total) / total_count
      end
    end
  end
end
