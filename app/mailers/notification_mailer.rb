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

    @summary = summary
    @token = notification.token
    mail to: notification.email, subject: "BitShares AGS donation has finished successfully at UTC 2014-07-19 00:00:00."
  end
end
