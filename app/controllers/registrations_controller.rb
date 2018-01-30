class RegistrationsController < ApplicationController
  before_action :authenticate_user!

  # GET /registrations
  # GET /registrations.json
  def index
    # Only loading 50 for now
    @registrations = Registration.all.limit(50)
  end
end
