module Ags
  ISSURANCE = {
    btc: 5_000,
    pts: 5_000
  }

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