class UpdateBtsToBtsx < ActiveRecord::Migration
  def change
    DacGenesis.where(dac: 'BTS').update_all("amount = amount * 500, dac = 'BTSX'")
  end
end