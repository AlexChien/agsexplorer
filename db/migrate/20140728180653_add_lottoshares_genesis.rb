# -*- encoding : utf-8 -*-
class AddLottosharesGenesis < ActiveRecord::Migration
  def import_data(addresses)
    addresses.each { |data| data.push('LTS') }

    DacGenesis.import [:address, :amount, :dac], addresses, validate: false
  end

  def up
    # angelshares
    addresses = []
    File.read("#{Rails.root}/db/migrate/lottoshares/angelshares.txt").each_line do |line|
      address, amount = line.gsub("\n","").split(':')
      addresses.push([address, amount])
    end
    import_data(addresses)

    # bitcoin
    addresses = []
    File.read("#{Rails.root}/db/migrate/lottoshares/bitcoin.txt").each_line do |line|
      address = line.gsub("\n","")
      addresses.push([address, 2_000_000_000])
    end
    import_data(addresses)

    # protoshares
    addresses = []
    File.read("#{Rails.root}/db/migrate/lottoshares/protoshares.txt").each_line do |line|
      address, amount = line.gsub("\n","").split(':')
      addresses.push([address, amount])
    end
    import_data(addresses)

    # thirty percent
    addresses = []
    File.read("#{Rails.root}/db/migrate/lottoshares/thirtypercent.txt").each_line do |line|
      nickname, address, amount = line.gsub("\n","").split(',')
      addresses.push([address, amount])
    end
    import_data(addresses)

    # thirty percent 2
    addresses = []
    File.read("#{Rails.root}/db/migrate/lottoshares/thirtypercent2.txt").each_line do |line|
      nickname, address, amount = line.gsub("\n","").split(',')
      addresses.push([address, amount])
    end
    import_data(addresses)

    # dogecoin
    # skip

    # memorycoin
    # skip

    # block5313
    # skip


    # performance issue, using activerecord-import gem for bulk insert
    # addresses.each do |data|
    #   DacGenesis.create(dac: 'LTS', address: data[0], amount: data[1].to_i)
    # end


  end

  def down
    DacGenesis.where(dac: 'LTS').delete_all
  end
end
