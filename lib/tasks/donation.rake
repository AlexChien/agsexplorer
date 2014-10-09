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

  desc "daily tasks"
  task :daily => :environment do
    Donation.calculate_ags_reward
    # daily stuff
  end

  desc "reset: delete all data and rebuild"
  task :reset => :environment do
    # wipe db data
    Donation.delete_all
    Wallet.delete_all
    WalletAddress.delete_all

    # re-parse
    Donation.parse_all

    # re-calculate each donation's confirmed ags_amount
    Rake::Task["donation:calculate_ags_reward_till"].invoke
  end

  desc "check ags address allocation against external quisquis data source"
  task :check_with_quisquis, [:network] => :environment do |t, args|
    network = args[:network] || 'btc'
    quis_json = File.join(Rails.root, "data", "#{network.downcase}_ags-2014-07-18.json")

    begin
      data = JSON.parse(File.read(quis_json))
    rescue
      data = nil
    end

    puts "data source error" and return false if data.nil?

    count = 0
    data["balances"].each do |addr|
      ags_total = Donation.where(network: network, address: addr.first).sum(:ags_amount)
      diff = ags_total - addr.second
      if diff > 5
        puts "UNMATCH: #{addr.first}: #{ags_total} vs #{addr.second} (#{diff})"
        count += 1
      end
    end

    puts "#{count} unmatches found"

    ags_addresses_total = Donation.where(network: network).select(:address).uniq.count
    quis_addresses_total = data["balances"].size
    if ags_addresses_total != quis_addresses_total
      puts "total entry count unmatch: #{ags_addresses_total} vs #{quis_addresses_total}"

      puts Donation.where(network: network).select(:address).uniq.map(&:address). - data["balances"].map(&:first).flatten
    end

  end
end