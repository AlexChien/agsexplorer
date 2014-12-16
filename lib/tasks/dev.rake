namespace :dev do
  desc "dev related tools"
  task :download_data => :environment do
    system "wget http://www1.agsexplorer.com/data/btc.csv.txt -O #{Rails.root}/data/btc.csv.txt"
    system "wget http://www1.agsexplorer.com/data/pts.csv.txt -O #{Rails.root}/data/pts.csv.txt"
  end

  namespace :validate do
    task :"20140102" => :environment do
      db_total = Donation.pts.by_date(Date.parse('2014-01-02')).sum(:amount)
      gtotal = 0.0
      File.read("#{Rails.root}/data/pts.csv.txt").each_line do |line|
        height, time, txbits, addr, amount, total, rate, related_addr = line.gsub("\"","").gsub("\n","").split(';')

        next unless time =~ /^2014-01-02/

        db_amount = Donation.where(txbits: txbits).first.amount

        puts "amount: #{db_amount} vs #{(amount.to_f * Ags::COIN).to_i}" if db_amount != (amount.to_f * Ags::COIN).to_i

        gtotal += amount.to_f
      end

      puts "recorded: 2983.98775972"
      puts "total: #{db_total} vs #{gtotal}"
    end
  end

  namespace :dac do
    namespace :bts do
      task :import_genesis => :environment do
        genesis_file = File.join(Rails.root, 'data', 'bts_genesis.json')

        g = JSON.parse(File.read(genesis_file))
        g["balances"].each do |r|
          DacGenesis.create(dac: 'BTS', address: r.first, amount: r.last)
        end
      end
    end

    namespace :dns do
      task :import_genesis => :environment do
        genesis_file = File.join(Rails.root, 'data', 'dns_genesis.json')

        g = JSON.parse(File.read(genesis_file))
        g["balances"].each do |r|
          DacGenesis.create(dac: 'DNS', address: r.first, amount: r.last)
        end
      end
    end

    namespace :vote do
      task :import_genesis => :environment do
        genesis_file = File.join(Rails.root, 'data', 'pts-2014-08-20.json')

        dac_name = 'VOTE'

        DacGenesis.where(dac: dac_name).delete_all

        # process PTS allocation
        g = JSON.parse(File.read(genesis_file))
        total_supply = g["balances"].inject(0){ |m,n| m + n.second }
        rate = 1_500_000_000.0 / total_supply
        g["balances"].each do |r|
          p "#{r.first}: #{r.second} - #{(r.second.to_f * Vote::COIN * rate).to_i}"

          DacGenesis.create(dac: 'VOTE', address: r.first,
                            amount: (r.second.to_f * Vote::COIN * rate).to_i)
        end
        p total_supply
        p rate

        # process AGS allocation
        # actual total ags is 199000000000102, need to confirm with note snapshot
        # if they use theory supply or actual supply
        ags_supply = 2_000_000 * Vote::COIN
        rate = 1_500_000_000.0 / ags_supply
        Donation.select(:address).group(:address).sum(:ags_amount).each do |r|
          DacGenesis.create(dac: 'VOTE', address: r.first,
                            amount: (r.second.to_f * Vote::COIN * rate).to_i)
        end
        p ags_supply
        p rate
      end
    end

    namespace :music do

      task :download_data => :environment do
        system "wget http://www1.agsexplorer.com/data/music.v2.csv.txt -O #{Rails.root}/data/music.v2.csv.txt"
      end

      # snapshot taken on 2014-10-10, pts holder will be granted 35% of total supply (1,500,000,000)
      task :import_genesis_pts => :environment do
        genesis_file = File.join(Rails.root, 'data', 'pts-2014-10-09.json')
        dac_name = 'MUSIC-PTS'

        # wipe out old entries
        DacGenesis.where(dac: dac_name).delete_all

        g = JSON.parse(File.read(genesis_file))
        total_supply = g["balances"].inject(0){ |m,n| m + n.second }
        rate = 525_000_000.0 / total_supply
        g["balances"].each do |r|
          p "#{r.first}: #{r.second} - #{(r.second.to_f * MusicPresale::COIN * rate).to_i}"
          DacGenesis.create(dac: dac_name,
                            address: r.first,
                            amount: (r.second.to_f * MusicPresale::COIN * rate).to_i)
        end
        p total_supply
        p rate
      end
    end

    namespace :play do
      task :import_genesis => :environment do
        [
          { name: "play-ags", file: 'ags_20140718.json', total_key: "moneysupply" },
          { name: "play-pts", file: 'pts_20141105.json', total_key: "moneysupply" },
          { name: "play-bts", file: 'bts_20141208.json', total_key: "total" }
        ].each do |dac|
          genesis_file = File.join(Rails.root, 'data', 'play', dac[:file])
          dac_name = dac[:name].upcase

          # wipe out old entries
          DacGenesis.where(dac: dac_name).delete_all

          g = JSON.parse(File.read(genesis_file))
          g["balances"].each do |r|
            DacGenesis.create(dac: dac_name,
                              address: r.first,
                              amount: r.second * 1000)
          end
        end
      end
    end

  end
end