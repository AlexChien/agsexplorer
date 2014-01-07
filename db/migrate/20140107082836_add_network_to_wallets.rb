class AddNetworkToWallets < ActiveRecord::Migration
  def change
    add_column :wallets, :network, :string
  end
end
