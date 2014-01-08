class AddTxbitToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :txbits, :string
  end
end
