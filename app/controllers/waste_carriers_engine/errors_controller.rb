# frozen_string_literal: true

module WasteCarriersEngine
  class ErrorsController < ApplicationController
    def show
      render(
        template: file_for(template),
        locals: { message: exception.try(:message) },
        status: (template_exists(error_code) ? error_code : "500")
      )
    end

    protected

    def error_code
      @error_code ||= params[:status]
    end

    def template_exists(name)
      File.exist?(template_path(name))
    end

    def template_path(name)
      File.expand_path(
        "app/views/#{file_for(name)}.html.erb",
        WasteCarriersEngine::Engine.root
      )
    end

    def template
      @template ||= template_exists(error_code) ? error_code : "generic"
    end

    def file_for(name)
      "waste_carriers_engine/errors/error_#{name}"
    end

    def exception
      env["action_dispatch.exception"]
    end
  end
end
