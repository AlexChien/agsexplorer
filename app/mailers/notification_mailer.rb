class NotificationMailer < ActionMailer::Base
  helper ApplicationHelper

  default from: "no-reply@agsexplorer.com"

  def daily(email, data = nil)
    return false if data.nil?

    @data = data
    mail to: email, subject: "#{Time.now.utc} AGSExplorer Daily Notification"
  end
end
