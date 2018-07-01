module WasteCarriersEngine
  class PostcodeForm < BaseForm
    private

    def format_postcode(postcode)
      return unless postcode.present?
      postcode.upcase!
      postcode.strip!
    end
  end
end
