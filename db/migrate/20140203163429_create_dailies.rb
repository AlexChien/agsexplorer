class CreateDailies < ActiveRecord::Migration
  def change
    create_table :dailies do |t|
      t.string :network, :default => 'btc'
      t.date :date
      t.integer :price, :limit => 8
      t.integer :amount, :limit => 8

      t.timestamps
    end

    add_index :dailies, :network
    add_index :dailies, :date
  end
end