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

    namespace :music do
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

  end
end