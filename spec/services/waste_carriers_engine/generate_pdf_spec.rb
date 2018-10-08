require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GeneratePdfService do
    context "when initialized with a string" do
      let(:generate_pdf_service) { GeneratePdfService.new("<h1>Hello There!</h1>") }

      it "generates a pdf" do
        # There doesn't appear to be any special way to confirm its a PDF other
        # than checking the string returned starts with this
        expect(generate_pdf_service.pdf).to start_with("%PDF-")
      end
    end

    context "when initialized with null" do
      let(:generate_pdf_service) { GeneratePdfService.new(nil) }

      it "does not generate a pdf" do
        expect(generate_pdf_service.pdf).to be_nil
      end
    end

  end
end
