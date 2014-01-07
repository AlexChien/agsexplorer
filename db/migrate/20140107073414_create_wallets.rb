class CreateWallets < ActiveRecord::Migration
  def change
    create_table :wallets do |t|
      t.string :wallet_id, :null => false, :unqiue => true
      t.text :addresses
      t.integer :ags_amount, :limit => 8

      t.timestamps
    end

    add_index :wallets, :wallet_id
  end
end