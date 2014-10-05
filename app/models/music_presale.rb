module MusicPresale
  COIN = 100_000_000

  ISSURANCE = {
    btc: 5_000_000 * COIN
  }

  END_DATE = Time.utc('2014','12','05')

  def self.daily_issue(network = "btc")
    ISSURANCE[network.to_sym]
  end

  def self.issued(network = btc, date = Time.now.utc.to_date)
    (date - Date.parse('2014-10-06')).to_i * daily_issue(network)
  end

  def self.total_issued(date = Time.now.utc.to_date)
    issued('btc', date)
  end
end