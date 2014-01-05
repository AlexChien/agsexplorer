class Donation < ActiveRecord::Base
  attr_accessible :address, :amount, :block_height, :network, :time, :rate, :total

  scope :btc, where(network: 'btc')
  scope :pts, where(network: 'pts')
  scope :date_grouping, select("network, date(time) as day, sum(amount) as total").group("network, date(time)").order("network, date(time)")

  def self.today_donations
    today = Time.now.utc.to_date
    where("time > ? and time < ?", today, today.tomorrow).order("time desc")
  end

  def self.current_price(network)
    # if no one has donated yet, you can all of it
    @@current_price ||= {}
    @@current_price[network.to_sym] ||= if today_donated(network) == 0 || today_donated(network).nil?
      Ags.daily_issue.to_f
    else
      Ags.daily_issue.to_f / today_donated(network) * Ags::COIN
    end
  end

  # specific date's date
  # TODO: Day 1
  def self.by_date(date = Time.now.utc.to_date)
    date_grouping.where("time > ? and time < ?", date, date.tomorrow)
  end

  def self.today_donated(network)
    @@today_donated ||= {}
    @@today_donated[network.to_sym] ||= date_grouping.by_date.where(network: network).try(:first).try(:total) || 0
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

    # v1
    # url ||= "http://q39.qhor.net/ags/{network}.txt?#{Time.now.to_i}".gsub('{network}', network)
    # v2
    url ||= "http://q39.qhor.net/ags/{network}.csv.txt?#{Time.now.to_i}".gsub('{network}', network)

    begin
      RestClient.get(url){ |response, request, result, &block|
        case response.code
        when 200
          parse_response(response, network)
        else
          response.return!(request, result, &block)
        end
      }
    rescue => e
      puts e
    end
  end

  def self.parse_response(response, network = 'btc')
    highest_block = Donation.where(network: @network).maximum(:block_height).to_i

    response.each_line do |line|
      # if line =~ /^\d+/ #v1
      if line =~ /^"{0,1}\d+/
        # height, time, addr, amount, total, rate = line.split(';') #v1
        height, time, addr, amount, total, rate = line.gsub("\"","").split(';')
        amount = (amount.to_f * 100_000_000).round #store in satoshi
        total = (total.to_f * 100_000_000).round #store in satoshi
        rate = (rate.to_f * 100_000_000).round #store in satoshi

        if height.to_i >= highest_block and !Donation.exists?(block_height: height, time: time, address: addr, amount: amount, network: network, rate: rate, total: total)
          Donation.create(block_height: height, time: time, address: addr, amount: amount, network: network, rate: rate, total: total)
        end
      end
    end
  end
end
