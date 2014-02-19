class Wallet < ActiveRecord::Base
  # serialize :addresses, String
  attr_accessible :ags_amount, :wallet_id
  has_many :addresses, :class_name => "WalletAddress", :foreign_key => "wallet_id", :primary_key => "wallet_id", :dependent => :destroy
  has_many :donations, :foreign_key => "wallet_id", :primary_key => "wallet_id", :dependent => :nullify

  def ags_amount
    @ags_amount ||= donations.sum(:ags_amount)
  end
end
