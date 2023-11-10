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
        registration_received_pending_conviction_form
        registration_received_pending_govpay_payment_form
        registration_received_pending_payment_form
        renewal_complete_form
        renewal_received_pending_conviction_form
        renewal_received_pending_govpay_payment_form
        renewal_received_pending_payment_form
        deregistration_complete_form
      ].freeze

      field :journey_type, type: String
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
        where(
          :created_at.gte => start_date.midnight,
          :created_at.lt => end_date.midnight + 1.day
        ).and(
          :$or => [
            { completed_at: nil },
            { :completed_at.gte => start_date.midnight, :completed_at.lt => end_date.midnight + 1.day }
          ]
        )
      }

      def self.minimum_created_at
        collection.aggregate([
                               { "$group" => {
                                 "_id" => nil,
                                 "minimumCreatedAt" => { "$min" => "$created_at" }
                               } }
                             ]).first["minimumCreatedAt"]&.in_time_zone
      rescue StandardError
        nil
      end

      def complete_journey(transient_registration)
        route = WasteCarriersEngine.configuration.host_is_back_office? ? "ASSISTED_DIGITAL" : "DIGITAL"
        update(completed_at: Time.zone.now)
        update(completed_route: route)
        update(registration_data: transient_registration.attributes.slice(
          "businessType",
          "declaredConvictions",
          "registrationType",
          "tier"
        ))
      end

      def self.average_duration(user_journey_scope)
        total = user_journey_scope.sum { |uj| uj.updated_at.to_time - uj.created_at.to_time }
        count = user_journey_scope.count

        return 0 unless count.positive?

        total / count
      end
    end
  end
end
