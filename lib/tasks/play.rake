namespace :play do
  desc "calculate donation's confirmed ags reward for a specific day"
  task :calculate_ags_reward, [:date, :networks] => :environment do |t, args|
    if args[:date]
      date = Date.parse(args[:date])
    else
      date = Time.zone.now.to_date.yesterday.beginning_of_day
    end

    PlayDonation.calculate_ags_reward(date,args[:networks])
  end

  desc "calculate donation's confirmed ags reward from day1 till the given date"
  task :calculate_ags_reward_till, [:date, :networks] => :environment do |t, args|
    if args[:date]
      to_date = Date.parse(args[:date])
    else
      to_date = Time.zone.now.to_date.yesterday
    end

    day1 = PlayCrowdfund::START_DATE.to_date

    (day1..to_date).each do |date|
      PlayDonation.calculate_ags_reward(date,args[:networks])
    end
  end

  desc "daily tasks"
  task :daily => :environment do
    PlayDonation.calculate_ags_reward
    # daily stuff
  end

  desc "reset: delete all data and rebuild"
  task :reset => :environment do
    # wipe db data
    PlayDonation.delete_all
    PlayDaily.delete_all
    # Wallet.delete_all
    # WalletAddress.delete_all

    # re-parse
    PlayDonation.parse_all

    # re-calculate each donation's confirmed ags_amount
    Rake::Task["play:calculate_ags_reward_till"].invoke
  end
end