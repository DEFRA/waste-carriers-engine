class DeviseNotifyMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers

  def reset_password_instructions(record, token, opts = {})
    send_via_gov_notify(:reset_password_instructions, record, opts.merge(token: token))
  end

  def unlock_instructions(record, token, opts = {})
    send_via_gov_notify(:unlock_instructions, record, opts.merge(token: token))
  end

  private

  def send_via_gov_notify(template, record, opts)
    WasteCarriersEngine::Notify::DeviseSender.run(template: template, record: record, opts: opts)
  end
end
