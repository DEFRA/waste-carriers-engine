# frozen_string_literal: true

module WasteCarriersEngine
  module JourneyLinksHelper
    def renewal_finished_link(*)
      # Designed to be overridden in host apps if needed
      main_app.root_path
    end
  end
end
