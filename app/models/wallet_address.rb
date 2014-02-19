class WalletAddress < ActiveRecord::Base
  belongs_to :wallet, primary_key: :wallet_id

  validates :address, :uniqueness => true, :presence => true

  attr_accessible :ags_amount, :wallet_id, :address, :donation_total

end
