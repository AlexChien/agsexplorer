class CreateWalletAddresses < ActiveRecord::Migration
  def change
    remove_column :wallets, :addresses

    create_table :wallet_addresses do |t|
      t.string :wallet_id
      t.string :address
      t.timestamps
    end

    add_index :wallet_addresses, :wallet_id
    add_index :wallet_addresses, :address
  end
end