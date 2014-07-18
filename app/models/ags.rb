module Ags
  COIN = 100_000_000

  ISSURANCE = {
    btc: 5_000 * COIN,
    pts: 5_000 * COIN
  }

  END_DATE = Time.utc('2014','07','19')

  def self.daily_issue(network = "btc")
    ISSURANCE[network.to_sym]
  end

  def self.issued(network = btc, date = Time.now.utc.to_date)
    (date - Date.parse('2014-01-01')).to_i * daily_issue(network)
  end

  def self.total_issued(date = Time.now.utc.to_date)
    issued('btc', date) + issued('pts', date)
  end
end