class Donation < ActiveRecord::Base
  attr_accessible :address, :amount, :block_height, :network, :time, :rate, :total, :ags_amount, :wallet_id, :txbits, :related_addresses
  serialize :related_addresses, Array


  belongs_to :wallet, primary_key: :wallet_id

  scope :btc, where(network: 'btc')
  scope :pts, where(network: 'pts')
  scope :date_grouping, select("network, date(time) as day, sum(amount) as total").group("network, date(time)").order("network, date(time)")

  def confirmed?
    time < Time.zone.now.to_date.beginning_of_day
  end

  def self.get_balance(addr, network = nil)
    get_donations_by_address(addr).sum(:amount)
  end

  def self.get_donations_by_address(addr, network = nil)
    Donation.where(address: addr).order('time desc')
  end

  def self.today_donations
    today = Time.zone.now.to_date
    where("time >= ? and time < ?", today, today.tomorrow).order("time desc")
  end

  def self.current_price(network)
    # if no one has donated yet, you can all of it
    # @@current_price ||= {}
    # @@current_price[network.to_sym] ||=
    if today_donated(network) == 0 || today_donated(network).nil?
      Ags.daily_issue.to_f
    else
      Ags.daily_issue.to_f / today_donated(network) * Ags::COIN
    end
  end

  # specific date's date
  # TODO: Day 1
  def self.by_date(date = Time.zone.now.to_date.beginning_of_day)
    date_grouping.where("time >= ? and time < ?", date, date.tomorrow)
  end

  def self.today_donated(network)
    # @@today_donated ||= {}
    # @@today_donated[network.to_sym] ||=
    date_grouping.by_date.where(network: network).try(:first).try(:total) || 0
  end

  # daily data series
  def self.daily
    data = { btc_total:0, btc_avg:0, btc:[], pts_total:0, pts_avg:0, pts:[] }

    %w(btc pts).each do |network|
      d = Daily.send(network).asc.all
      data[network.to_sym] = d.collect{ |record| record.as_json(only: [:date, :amount]) }
      data["#{network}_total".to_sym] = d.inject(0){ |m,n| m+n[:amount] } + today_donated(network)
      data["#{network}_avg".to_sym] = data["#{network}_total".to_sym] / (d.length + 1)
    end

    data
  end

  def self.daily_v1
    data = { btc_total:0, btc_avg:0, btc:[], pts_total:0, pts_avg:0, pts:[] }
    pre_day1 = {btc:0, pts:0}

    date_grouping.each do |d|
      next if d.attributes.keys.any?{ |key| d[key].blank? }

      total = d.total.to_i
      data["#{d.network}_total".to_sym] += total

      if Date.parse(d.day) < Date.parse('2014-01-01')
        pre_day1[d.network.to_sym] += total
      else
        data[d.network.to_sym].push({date: d.day, amount: total})
        data["#{d.network}_avg".to_sym] += total
      end

    end

    %w(btc pts).each do |network|
      sym = network.to_sym

      data[sym].first[:amount] += pre_day1[sym]
      data["#{network}_avg".to_sym] += pre_day1[sym]
      data["#{network}_avg".to_sym] = data["#{network}_avg".to_sym] / data[sym].length

    end

    data
  end

  def self.parse_all
    %w(btc pts).map{ |n| parse(n) }
  end

  def self.parse(network = "btc", url = nil)
    @network = case network.to_s
    when "bitcoin"
      "btc"
    when "pts", "protoshare"
      "pts"
    else
      "btc"
    end

    # v0.1
    # url ||= "http://q39.qhor.net/ags/{network}.txt?#{Time.now.to_i}".gsub('{network}', network)
    # v0.2
    # url ||= "http://q39.qhor.net/ags/{network}.csv.txt?#{Time.now.to_i}".gsub('{network}', network)
    # v0.3
    # url ||= "http://q39.qhor.net/ags/3/{network}.csv.txt?#{Time.now.to_i}".gsub('{network}', network)
    # v0.4
    # url ||= "http://cryptoseed.cloudapp.net:81/ags/4/{network}.csv.txt?#{Time.now.to_i}".gsub('{network}', network)
    # v0.5
    # url ||= "http://q39.qhor.net/ags/5/{network}.csv.txt?#{Time.now.to_i}".gsub('{network}', network)

    # local data vin0
    url ||= File.join(Rails.root, 'data', "{network}.csv.txt".gsub('{network}', network))

    puts "[#{Time.now.to_s(:db)}] Donation: parse network #{url}"

    begin
      uri = URI.parse(url)
      if uri.scheme =~ /^http/
        RestClient.get(url){ |response, request, result, &block|
          case response.code
          when 200
            parse_response(response, network)
            # check_total(response, network)
          else
            response.return!(request, result, &block)
          end
        }
      else
        parse_response(File.read(url), network) if File.exists?(url)
      end

    rescue => e
      puts e
    end
  end

  def self.parse_response(response, network = 'btc')
    self.parse_response_vin0(response, network)
  end

  # parse v0.2 api
  def self.parse_response_v2(response, network = 'btc')
    highest_block = Donation.where(network: @network).maximum(:block_height).to_i

    oheight, oaddr, ototal, orate = nil,nil,nil,nil
    response.each_line do |line|
      # if line =~ /^\d+/ #v1
      if line =~ /^"{0,1}\d+/
        # height, time, addr, amount, total, rate = line.split(';') #v1
        height, time, addr, amount, total, rate = line.gsub("\"","").split(';')
        amount = (amount.to_f * 100_000_000).round #store in satoshi
        total = (total.to_f * 100_000_000).round #store in satoshi
        rate = (rate.to_f * 100_000_000).round #store in satoshi

        if height.to_i >= highest_block and !Donation.exists?(block_height: height, time: time, address: addr, amount: amount, network: network, rate: rate, total: total)

          # assign wallet_id
          if height == oheight && total == ototal && rate == orate
            brother_addr = oaddr

            wallet_id = Donation.where(network: network, address: brother_addr).limit(1).first.try(:wallet_id)
            my_addr_wallet_id = Donation.where(network: network, address: addr).limit(1).first.try(:wallet_id)

            if my_addr_wallet_id
              Donation.where(network: network, wallet_id: my_addr_wallet_id).update_all(wallet_id: wallet_id)
            end
          end

          wallet_id ||= Donation.where(network: network, address: addr).limit(1).first.try(:wallet_id)
          if wallet_id.nil?
            wallet_id = SecureRandom.hex(30)
          end

          Donation.create(block_height: height, time: time, address: addr, amount: amount, network: network, rate: rate, total: total, ags_amount: 0, wallet_id: wallet_id)

          # update wallet
          wallet = Wallet.find_or_initialize_by_wallet_id(wallet_id)
          unless wallet.addresses.include?(addr)
            wallet.addresses = wallet.addresses.push(addr)
            wallet.network = network
            wallet.save
          end

          oheight, oaddr, ototal, orate = height, addr, total, rate

        end
      end
    end
  end

  # parse v0.3 api
  def self.parse_response_v3(response, network = 'btc')
    highest_block = Donation.where(network: @network).maximum(:block_height).to_i

    otxbits, oaddr = nil, nil
    response.each_line do |line|
      # if line =~ /^\d+/ #v1
      if line =~ /^"{0,1}\d+/
        # height, time, addr, amount, total, rate = line.split(';') #v1
        height, time, txbits, addr, amount, total, rate = line.gsub("\"","").split(';')
        amount = (amount.to_f * 100_000_000).round #store in satoshi
        total = (total.to_f * 100_000_000).round #store in satoshi
        rate = (rate.to_f * 100_000_000).round #store in satoshi

        if height.to_i >= highest_block and !Donation.exists?(block_height: height, time: time, address: addr, amount: amount, network: network, rate: rate, total: total)

          # assign wallet_id
          if txbits == otxbits
            brother_addr = oaddr

            wallet_id = Donation.where(network: network, address: brother_addr).limit(1).first.try(:wallet_id)
            my_addr_wallet_id = Donation.where(network: network, address: addr).limit(1).first.try(:wallet_id)

            if my_addr_wallet_id
              Donation.where(network: network, wallet_id: my_addr_wallet_id).update_all(wallet_id: wallet_id)
            end
          end

          wallet_id ||= Donation.where(network: network, address: addr).limit(1).first.try(:wallet_id)
          if wallet_id.nil?
            wallet_id = SecureRandom.hex(30)
          end

          Donation.create(block_height: height, time: time, address: addr, amount: amount, network: network, rate: rate, total: total, ags_amount: 0, wallet_id: wallet_id, txbits: txbits)

          # update wallet
          wallet = Wallet.find_or_initialize_by_wallet_id(wallet_id)
          unless wallet.addresses.include?(addr)
            wallet.addresses = wallet.addresses.push(addr)
            wallet.network = network
            wallet.save
          end

          otxbits, oaddr = txbits, addr

        end
      end
    end
  end

  # parse v0.4 api
  def self.parse_response_v4(response, network = 'btc')
    highest_block = Donation.where(network: @network).maximum(:block_height).to_i

    otxbits, oaddr = nil, nil
    response.each_line do |line|
      # if line =~ /^\d+/ #v1
      if line =~ /^"{0,1}\d+/
        # height, time, addr, amount, total, rate = line.split(';') #v1
        height, time, txbits, addr, amount, total, rate = line.gsub("\"","").split(';')
        amount = (amount.to_f * 100_000_000).to_i #store in satoshi
        total = (total.to_f * 100_000_000).to_i #store in satoshi
        rate = (rate.to_f * 100_000_000).to_i #store in satoshi

        if height.to_i >= highest_block and !Donation.exists?(block_height: height, time: time, address: addr, amount: amount, network: network, rate: rate, total: total)

          # assign wallet_id
          if txbits == otxbits
            brother_addr = oaddr

            wallet_id = Donation.where(network: network, address: brother_addr).limit(1).first.try(:wallet_id)
            my_addr_wallet_id = Donation.where(network: network, address: addr).limit(1).first.try(:wallet_id)

            if my_addr_wallet_id
              Donation.where(network: network, wallet_id: my_addr_wallet_id).update_all(wallet_id: wallet_id)
            end
          end

          wallet_id ||= Donation.where(network: network, address: addr).limit(1).first.try(:wallet_id)
          if wallet_id.nil?
            wallet_id = SecureRandom.hex(30)
          end

          Donation.create(block_height: height, time: time, address: addr, amount: amount, network: network, rate: rate, total: total, ags_amount: 0, wallet_id: wallet_id, txbits: txbits)

          # update wallet
          wallet = Wallet.find_or_initialize_by_wallet_id(wallet_id)
          unless wallet.addresses.include?(addr)
            wallet.addresses = wallet.addresses.push(addr)
            wallet.network = network
            wallet.save
          end

          otxbits, oaddr = txbits, addr

        end
      end
    end
  end

  # parse v0.5 api
  def self.parse_response_v5(response, network = 'btc')
    highest_block = Donation.where(network: @network).maximum(:block_height).to_i

    otxbits, oaddr = nil, nil
    response.each_line do |line|
      # if line =~ /^\d+/ #v1
      if line =~ /^"{0,1}\d+/
        # height, time, addr, amount, total, rate = line.split(';') #v1
        height, time, txbits, addr, change, amount, total, rate = line.gsub("\"","").split(';')
        amount = (amount.to_f * 100_000_000).to_i #store in satoshi
        total = (total.to_f * 100_000_000).to_i #store in satoshi
        rate = (rate.to_f * 100_000_000).to_i #store in satoshi

        if height.to_i >= highest_block and !Donation.exists?(block_height: height, time: time, address: addr, amount: amount, network: network, rate: rate, total: total)

          # assign wallet_id
          if txbits == otxbits
            brother_addr = oaddr

            wallet_id = Donation.where(network: network, address: brother_addr).limit(1).first.try(:wallet_id)
            my_addr_wallet_id = Donation.where(network: network, address: addr).limit(1).first.try(:wallet_id)

            if my_addr_wallet_id
              Donation.where(network: network, wallet_id: my_addr_wallet_id).update_all(wallet_id: wallet_id)
            end
          end

          wallet_id ||= Donation.where(network: network, address: addr).limit(1).first.try(:wallet_id)
          if wallet_id.nil?
            wallet_id = SecureRandom.hex(30)
          end

          Donation.create(block_height: height, time: time, address: addr, amount: amount, network: network, rate: rate, total: total, ags_amount: 0, wallet_id: wallet_id, txbits: txbits)

          # update wallet
          wallet = Wallet.find_or_initialize_by_wallet_id(wallet_id)
          unless wallet.addresses.include?(addr)
            wallet.addresses = wallet.addresses.push(addr)
            wallet.network = network
            wallet.save
          end

          otxbits, oaddr = txbits, addr

        end
      end
    end
  end


  # parse v0.4 api
  def self.parse_response_vin0(response, network = 'btc')
    highest_block = Donation.where(network: @network).maximum(:block_height).to_i

    # add 5 blocks tolerence
    # sometimes new block's time is older than highest_block
    # https://bitsharestalk.org/index.php?topic=2869.msg36543#msg36543
    highest_block -= 5

    response.each_line do |line|
      # binding.pry
      if line =~ /^"{0,1}\d+/
        # height, time, addr, amount, total, rate = line.split(';') #v1
        height, time, txbits, addr, amount, total, rate, related_addrs = line.strip.gsub('"','').split(';')
        amount = (amount.to_f * 100_000_000).to_i #store in satoshi
        total = (total.to_f * 100_000_000).to_i #store in satoshi
        rate = (rate.to_f * 100_000_000).to_i #store in satoshi
        related_addrs = related_addrs.nil? ? [] : related_addrs.split(',')
        (related_addrs.unshift addr).uniq!

        if height.to_i >= highest_block and !Donation.exists?(txbits: txbits)

          # find wallet id for existed donation address
          wallet_id = Donation.where(network: network, address: addr).limit(1).first.try(:wallet_id)

          # if donation wallet is found directly
          if not wallet_id.nil?
            # update any newly linked addresses's wallet_id
            [WalletAddress, Donation].each do |mod|
              mod.where(address: related_addrs)
                  .where("wallet_id != ?", wallet_id)
                  .update_all(wallet_id: wallet_id)
            end
          else
            # looking for indirectly related wallet by wallet addresses
            wallet_ids = WalletAddress.where(address: related_addrs).map(&:wallet_id).uniq

            if not wallet_ids.empty?
              wallet_id = wallet_ids.first

              # only update wallet_id when there were multiple wallets
              # they get a chance to link up
              if wallet_ids.size > 1
                WalletAddress.where(address: related_addrs).update_all(wallet_id: wallet_id)
              end
            end
          end

          # nothing found, new wallet
          if wallet_id.nil?
            wallet_id = SecureRandom.hex(30)
          end

          # store the donation
          Donation.create(block_height: height, time: time, address: addr, amount: amount, network: network, rate: rate, total: total, ags_amount: 0, wallet_id: wallet_id, txbits: txbits, related_addresses: related_addrs-[addr])

          # update wallet
          wallet = Wallet.find_or_initialize_by_wallet_id(wallet_id)
          wallet.network = network
          wallet_addresses = wallet.addresses.map(&:address)
          new_addresses = (related_addrs - wallet_addresses).uniq
          new_addresses.each do |new_addr|
            WalletAddress.create(address: new_addr, wallet_id: wallet_id)
          end
          wallet.save if wallet.changed?

        end
      end
    end
  end

  # calcuated actual ags can be obtained in the past day
  # a cronjob should be prepared and run at beginning of utc day everyday
  # by default, calculate yesterday's reward
  def self.calculate_ags_reward(date = Time.zone.now.to_date.yesterday.beginning_of_day, networks = [])
    ns = [:btc, :pts]
    unless networks.to_a.empty?
      ns = ns & networks.to_a.map(&:to_sym)
    end

    date = Date.parse(date) if date.is_a? String

    puts "[#{Time.now.to_s(:db)}] Donation calculate_ags_reward #{date.to_s(:ymd)}"

    ns.each do |network|
      # day1 should include all before jan 1st
      if date < Date.parse('2014-01-02')
        total_donations = self.send(network).where("time < '2014-01-02'")
      else
        total_donations = self.send(network).where('time >= ? and time < ?', date, date.tomorrow)
      end

      total_amount = total_donations.sum(:amount)
      return false if total_amount <= 0
      price =  Ags::ISSURANCE[network.to_sym].to_f / total_amount

      total_donations.update_all(["ags_amount = amount * ?, today_total_donation = ?, today_price = ?", price, total_amount, (price * Ags::COIN).round])

      # update daily cache table
      daily = Daily.find_or_initialize_by_network_and_date(network, date)
      daily.price = (price * Ags::COIN).round
      daily.amount = total_amount
      daily.save
    end
  end

  # baseline data
  # {"BTC":[
  # [2013-01-01: 61.861694286294],
  # [2014-01-02: 54.312118818387],
  # [2014-01-03: 52.742818852115],
  # [2014-01-04: 69.206746369135],
  # [2014-01-05: 55.873671190435],
  # [2014-01-06: 41.049251734832]]
  #
  # "PTS":[
  # [2013-01-01,2343.9963135793],
  # [2014-01-02,2983.9877512266],
  # [2014-01-03,2679.7434171562],
  # [2014-01-04,2681.5032923108],
  # [2014-01-05,2733.9719749189],
  # [2014-01-06,2889.5240458697],
  # [2013-01-07,3050.0523216445],
  # [2014-01-08,2385.7550195996]]}
  def self.check_total(response, network = 'btc')
    odate = '2013-01-01'
    gtotal = 0.0
    response.each_line do |line|
      if line =~ /^"{0,1}\d+/
        height, time, txbits, addr, change, amount, total, rate = line.gsub("\"","").split(';')
        date = time.split(' ')[0]

        # new day starts
        if date > odate && date > '2014-01-01'
          puts "#{odate}: #{gtotal}"
          odate = date
          gtotal = 0
        end

        gtotal += amount.to_f.round(8)

        if gtotal.round(8) != total.to_f
          binding.pry
        end
      end
    end
  end


end
