class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.integer :block_height, :null => false
      t.datetime :time, :null => false
      t.string :address, :null => false
      t.integer :amount, :null => false, :limit => 8
      t.string :network, :default => 'bitcoin'

      t.timestamps
    end

    add_index :donations, :network
    add_index :donations, :address
    add_index :donations, :time
    add_index :donations, :block_height

  end
end