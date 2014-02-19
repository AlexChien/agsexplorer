class RemoveAgsAmountFromWallet < ActiveRecord::Migration
  def change
    remove_column :wallets, :ags_amount
  end
end
