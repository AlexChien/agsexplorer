class CreateTickers < ActiveRecord::Migration
  def change
    create_table :tickers do |t|
      t.string :market
      t.string :pair
      t.decimal :last, :scale => 2, :precision => 8

      t.timestamps
    end

    add_index :tickers, [:market, :pair]
    add_index :tickers, :created_at
  end
end