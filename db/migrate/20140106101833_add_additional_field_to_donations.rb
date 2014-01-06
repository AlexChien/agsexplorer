class AddAdditionalFieldToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :today_total_donation, :integer, :limit => 8
    add_column :donations, :today_price, :integer, :limit => 8
  end
end