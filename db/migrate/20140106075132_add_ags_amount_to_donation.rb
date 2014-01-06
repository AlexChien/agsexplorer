class AddAgsAmountToDonation < ActiveRecord::Migration
  def change
    add_column :donations, :ags_amount, :integer, :limit => 8
  end
end
