class AddDefaultValueToNewlyAddedFields < ActiveRecord::Migration
  def change
    change_column_default :donations, :ags_amount, 0
    change_column_default :donations, :today_total_donation, 0
    change_column_default :donations, :today_price, 0
  end
end