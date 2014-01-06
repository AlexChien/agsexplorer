class AddWalletIdToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :wallet_id, :string

    add_index :donations, :wallet_id
  end
end