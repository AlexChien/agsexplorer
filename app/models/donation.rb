class Donation < ActiveRecord::Base
  attr_accessible :address, :amount, :block_height, :network, :time

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
        height, time, addr, sum = line.split(';')
        sum = (sum.to_f * 100_000_000).round #store in satoshi

        if height.to_i >= highest_block and !Donation.exists?(block_height: height, time: time, address: addr, amount: sum, network: @network)
          Donation.create(block_height: height, time: time, address: addr, amount: sum, network: @network)
        end
      end
    end
  end
end
