# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "/home/mongrel/agsexplorer/shared/log/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# fetch new blockchain data every 1 minutes
every 1.minutes do
  runner "Donation.parse_all"
end

# fetch tickers every 1 minute
every 1.minute do
  runner "Ticker.fetch_tickers"
end

# update past day's ags amount actually accquired
every 1.day, :at => '8:01 am' do
  # calculate each donation obtained ags reward for yesterday
  runner "Donation.calculate_ags_reward"

  # re-calculate each wallet's total ags amount obtained from its all addresses
  runner "Wallet.calculate_ags_sum"
end

# every day at 5am, 3 hours before end of day
every 1.day, :at => '5:00 am' do
  # send daily email
  rake 'email:daily'
end