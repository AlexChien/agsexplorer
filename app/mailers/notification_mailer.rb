class NotificationMailer < ActionMailer::Base
  helper ApplicationHelper

  default from: "no-reply@agsexplorer.com"

  def daily(notification, data = nil)
    return false if data.nil?

    @data = data
    @token = notification.token
    mail to: notification.email, subject: "#{Time.now.utc} AGSExplorer Daily Notification"
  end

  def summary(notification, summary = nil)
    return false if summary.nil?

    @summary = data
    @token = notification.token
    mail to: notification.email, subject: "#{Time.now.utc} AGSExplorer Daily Notification: Bitshares AGS donation has finished successfully."
  end
end
