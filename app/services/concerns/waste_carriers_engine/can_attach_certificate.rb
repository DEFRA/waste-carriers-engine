# frozen_string_literal: true

module WasteCarriersEngine
  module CanAttachCertificate
    extend ActiveSupport::Concern

    included do
      def link_to_certificate
        Notifications.prepare_upload(pdf)
      end

      def pdf
        StringIO.new(pdf_content)
      end

      def pdf_content
        ActionController::Base.new.render_to_string(
          pdf: "certificate",
          template: "waste_carriers_engine/pdfs/certificate",
          encoding: "UTF-8",
          layout: false,
          locals: { presenter: certificate_presenter }
        )
      end
    end
  end
end
