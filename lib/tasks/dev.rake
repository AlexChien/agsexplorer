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
  end
end