unless Rails.env.test?
  Agsexplorer::Application.config.action_mailer.delivery_method = :smtp

  Agsexplorer::Application.config.action_mailer.smtp_settings = {
    :address => APP_CONFIG[:email]["address"],
    :port => APP_CONFIG[:email]["port"],
    :domain => APP_CONFIG[:email]["domain"],
    :authentication => APP_CONFIG[:email]["authentication"],
    :user_name => APP_CONFIG[:email]["user_name"],
    :password => APP_CONFIG[:email]["password"],
    :default_charset => APP_CONFIG[:email]["default_charset"],
    :default_content_type => APP_CONFIG[:email]["default_content_type"]
  }
end