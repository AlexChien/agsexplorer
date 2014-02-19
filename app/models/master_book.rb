class MasterBook < ActiveRecord::Base
  attr_accessible :address, :ags_amount, :donation_amount, :network

  validates_presence_of :network, :address
end
