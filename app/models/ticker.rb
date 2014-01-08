class Ticker < ActiveRecord::Base
  attr_accessible :last, :market, :pair

  TICKERS = [
    { market: 'bter', pair: 'pts_btc', api_url: 'https://bter.com/api/1/ticker/pts_btc' },
    { market: 'bitstamp', pair: 'btc_usd', api_url: 'https://www.bitstamp.net/api/ticker/' }
  ]

  def self.fetch_tickers
    TICKERS.each do |ticker|
      begin
        puts "[#{Time.now.to_s(:db)}] Ticker: fetch #{ticker[:api_url]}"
        resp = RestClient.get ticker[:api_url], :timeout => 2
      rescue
        puts "resp is nil"
        resp = nil
      end

      parse(resp, ticker)
    end
  end

  def self.parse(resp, ticker)
    if resp
      resp = JSON.parse(resp)
      puts resp

      create(ticker.except(:api_url).merge(last: resp["last"])) if resp["last"]
    else
      puts "no response from #{ticker}"
    end
  end
end
