class AddRelatedAddressesToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :related_addresses, :text
  end
end
