class Wallet < ActiveRecord::Base
  # serialize :addresses, String
  attr_accessible :ags_amount, :wallet_id
  has_many :addresses, :class_name => "WalletAddress", :foreign_key => "wallet_id", :primary_key => "wallet_id", :dependent => :destroy
  has_many :donations, :foreign_key => "wallet_id", :primary_key => "wallet_id", :dependent => :nullify

  # calculate wallet sum
  # re-calculate from day 1 till yesterday for confirmed ags_amount
  def self.calculate_ags_sum
    puts "[#{Time.now.to_s(:db)}] Wallet: calculate_ags_sum"
    Wallet.find_each do |wallet|
      sp = Donation.scoped
      sp = sp.where(network: wallet.network)
      sp = sp.where("time < ?", Time.zone.now.to_date)
      confirmed_amount = sp.sum("ags_amount")

      wallet.update_attribute(:ags_amount, confirmed_amount)
    end
  end
end
