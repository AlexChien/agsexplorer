class Donation < ActiveRecord::Base
  attr_accessible :address, :amount, :block_height, :network, :time, :rate, :total, :ags_amount, :wallet_id, :txbits

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
    url ||= "http://q39.qhor.net/ags/3/{network}.csv.txt?#{Time.now.to_i}".gsub('{network}', network)

    begin
      RestClient.get(url){ |response, request, result, &block|
        case response.code
        when 200
          parse_response_v3(response, network)
        else
          response.return!(request, result, &block)
        end
      }
    rescue => e
      puts e
    end
  end

  # parse v0.2 api
  def self.parse_response(response, network = 'btc')
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

  # calcuated actual ags can be obtained in the past day
  # a cronjob should be prepared and run at beginning of utc day everyday
  # by default, calculate yesterday's reward
  def self.calculate_ags_reward(date = Time.zone.now.to_date.yesterday.beginning_of_day, networks = [])
    ns = [:btc, :pts]
    unless networks.to_a.empty?
      ns = ns & networks.to_a.map(&:to_sym)
    end

    date = Date.parse(date) if date.is_a? String

    ns.each do |network|
      # day1 should include all before jan 1st
      if date < Date.parse('2014-01-02')
        total_donations = self.send(network).where("time < '2014-01-02'")
      else
        total_donations = self.send(network).where('time >= ? and time < ?', date, date.tomorrow)
      end

      total_amount = total_donations.sum(:amount)
      return false if total_amount <= 0
      price =  Ags::ISSURANCE[network].to_f / total_amount

      total_donations.update_all(["ags_amount = amount * ?, today_total_donation = ?, today_price = ?", price, total_amount, price])
    end
  end

end
