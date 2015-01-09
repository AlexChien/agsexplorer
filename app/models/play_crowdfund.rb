module PlayCrowdfund
  COIN = 100_000_000
  TARGET_FUND = 3_000

  ISSURANCE = {
    btc: 130_000 * COIN
  }

  START_DATE = Time.utc('2015','01','05')
  END_DATE = Time.utc('2015','02','02')

  def self.daily_issue(network = "btc")
    ISSURANCE[network.to_sym]
  end

  def self.issued(network = 'btc', time = Time.now.utc)
    PlayDonation.where('time < ?', time).sum(:ags_amount)
  end

  def self.total_issued(network = 'btc', time = Time.now.utc)
    issued('btc', time)
  end

  # week passed
  # 0: 130_000
  # 1: 120_000
  # 2: 110_000
  # >=3: 100_000
  def self.current_price(week_passed)
    [130_000 - 10_000 * week_passed, 100_000].max
  end
end