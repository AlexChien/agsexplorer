class Donation < ActiveRecord::Base
  attr_accessible :address, :amount, :block_height, :network, :time, :rate, :total

  scope :btc, where(network: 'btc')
  scope :pts, where(network: 'pts')
  scope :date_grouping, select("network, date(time) as day, sum(amount) as total").group("network, date(time)").order("network, date(time)")

  # specific date's date
  # TODO: Day 1
  def self.by_date(date = Time.now.utc.to_date)
    date_grouping.where("time > ? and time < ?", date, date.tomorrow)
  end

  # daily data series
  def self.daily
    data = { btc_total:0, btc_avg:0, btc:[], pts_total:0, pts_avg:0, pts:[] }
    pre_day1 = {btc:0, pts:0}

    date_grouping.each do |d|
      next if d.attributes.keys.any?{ |key| d[key].blank? }

      total = (d.total / 100_000_000).to_i
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

    # data[:btc].first.amount += pre_day1[:btc]
    # data[:pts].first.amount += pre_day1[:pts]
    # data[:btc_avg] += pre_day1[:btc]
    # data[:pts_avg] += pre_day1[:pts]
    # data[:btc_avg] = data[:btc_avg] / data[:btc].length
    # data[:pts_avg] = data[:pts_avg] / data[:pts].length

    data
  end

  def self.parse_all
    %w(btc pts).map{ |n| parse(n) }
  end

  def self.parse(network = "btc")
    @network = case network.to_s
    when "bitcoin"
      "btc"
    when "pts", "protoshare"
      "pts"
    else
      "btc"
    end

    url = "http://q39.qhor.net/ags/{network}.txt?#{Time.now.to_i}".gsub('{network}', network)

    begin
      RestClient.get(url){ |response, request, result, &block|
        case response.code
        when 200
          parse_response(response)
        else
          response.return!(request, result, &block)
        end
      }
    rescue => e
      puts e
    end
  end

  def self.parse_response(response)
    highest_block = Donation.where(network: @network).maximum(:block_height).to_i

    response.each_line do |line|
      if line =~ /^\d+/
        height, time, addr, amount, total, rate = line.split(';')
        amount = (amount.to_f * 100_000_000).round #store in satoshi
        total = (total.to_f * 100_000_000).round #store in satoshi
        rate = (rate.to_f * 100_000_000).round #store in satoshi

        if height.to_i >= highest_block and !Donation.exists?(block_height: height, time: time, address: addr, amount: amount, network: @network, rate: rate, total: total)
          Donation.create(block_height: height, time: time, address: addr, amount: amount, network: @network, rate: rate, total: total)
        end
      end
    end
  end
end
