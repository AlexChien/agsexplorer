namespace :music_presale do
  desc "calculate donation's confirmed ags reward for a specific day"
  task :calculate_ags_reward, [:date, :networks] => :environment do |t, args|
    if args[:date]
      date = Date.parse(args[:date])
    else
      date = Time.zone.now.to_date.yesterday.beginning_of_day
    end

    MusicDonation.calculate_ags_reward(date,args[:networks])
  end

  desc "calculate donation's confirmed ags reward from day1 till the given date"
  task :calculate_ags_reward_till, [:date, :networks] => :environment do |t, args|
    if args[:date]
      to_date = Date.parse(args[:date])
    else
      to_date = Time.zone.now.to_date.yesterday
    end

    day1 = Date.parse('2014-10-06')

    (day1..to_date).each do |date|
      MusicDonation.calculate_ags_reward(date,args[:networks])
    end
  end

  desc "daily tasks"
  task :daily => :environment do
    MusicDonation.calculate_ags_reward
    # daily stuff
  end

  desc "reset: delete all data and rebuild"
  task :reset => :environment do
    # wipe db data
    MusicDonation.delete_all
    Wallet.delete_all
    WalletAddress.delete_all

    # re-parse
    MusicDonation.parse_all

    # re-calculate each donation's confirmed ags_amount
    Rake::Task["music_presale:calculate_ags_reward_till"].invoke
  end
end