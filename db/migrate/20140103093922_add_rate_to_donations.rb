class AddRateToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :rate, :integer, :limit => 8
    add_column :donations, :total, :integer, :limit => 8

    add_index :donations, :rate
    add_index :donations, :total
  end
end