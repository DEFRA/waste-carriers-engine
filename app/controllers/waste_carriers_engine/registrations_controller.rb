module WasteCarriersEngine
  class RegistrationsController < ApplicationController
    before_action :authenticate_user!

    # GET /registrations
    # GET /registrations.json
    def index
      # Only load the first 50 accessible by the current user
      puts current_ability
      @registrations = Registration.accessible_by(current_ability).limit(50)
    end
  end
end
