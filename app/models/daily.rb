class Daily < ActiveRecord::Base
  attr_accessible :amount, :date, :network, :price, :volume

  scope :btc, where(network: :btc)
  scope :pts, where(network: :pts)
  scope :asc, order("date asc")
end
