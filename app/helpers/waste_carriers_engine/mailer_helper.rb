# frozen_string_literal: true

module WasteCarriersEngine
  module MailerHelper
    # This ensures that an images we need to display in an email are shown by
    # adding them as attachments rather than exposing them as links to the
    # service. We have found this a more reliable method and is the same used as
    # in WEX and FRAE
    def email_image_tag(image, **)
      path = "/app/assets/images/#{image}"

      full_path = File.join(Rails.root, path)

      full_path = "#{Gem.loaded_specs['waste_carriers_engine'].full_gem_path}#{path}" unless File.exist?(full_path)

      attachments[image] = File.read(full_path)
      image_tag(attachments[image].url, **)
    end
  end
end
