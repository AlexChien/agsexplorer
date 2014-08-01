# -*- encoding : utf-8 -*-
class AddLottosharesGenesis < ActiveRecord::Migration
  def up
    addresses = []
    # angelshares
    File.read("#{Rails.root}/db/migrate/lottoshares/angelshares.txt").each_line do |line|
      address, amount = line.gsub("\n","").split(':')
      addresses.push([address, amount])
    end

    # bitcoin
    File.read("#{Rails.root}/db/migrate/lottoshares/bitcoin.txt").each_line do |line|
      address = line.gsub("\n","")
      addresses.push([address, 2_000_000_000])
    end

    # protoshares
    File.read("#{Rails.root}/db/migrate/lottoshares/protoshares.txt").each_line do |line|
      address, amount = line.gsub("\n","").split(':')
      addresses.push([address, amount])
    end

    # thirty percent
    File.read("#{Rails.root}/db/migrate/lottoshares/thirtypercent.txt").each_line do |line|
      nickname, address, amount = line.gsub("\n","").split(',')
      addresses.push([address, amount])
    end

    # thirty percent 2
    File.read("#{Rails.root}/db/migrate/lottoshares/thirtypercent2.txt").each_line do |line|
      nickname, address, amount = line.gsub("\n","").split(',')
      addresses.push([address, amount])
    end

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

    addresses.each { |data| data.push('LTS') }

    DacGenesis.import [:address, :amount, :dac], addresses, validate: false

  end

  def down
    DacGenesis.where(dac: 'LTC').delete_all
  end
end
