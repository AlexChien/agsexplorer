namespace :donation do
  desc "calculate donation's confirmed ags reward for a specific day"
  task :calculate_ags_reward, [:date, :networks] => :environment do |t, args|
    if args[:date]
      date = Date.parse(args[:date])
    else
      date = Time.zone.now.to_date.yesterday.beginning_of_day
    end

    Donation.calculate_ags_reward(date,args[:networks])
  end

  desc "calculate donation's confirmed ags reward from day1 till the given date"
  task :calculate_ags_reward_till, [:date, :networks] => :environment do |t, args|
    if args[:date]
      to_date = Date.parse(args[:date])
    else
      to_date = Time.zone.now.to_date.yesterday
    end

    day1 = Date.parse('2014-01-01')

    (day1..to_date).each do |date|
      Donation.calculate_ags_reward(date,args[:networks])
    end
  end

end