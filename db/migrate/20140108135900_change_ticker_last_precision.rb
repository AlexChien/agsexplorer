class ChangeTickerLastPrecision < ActiveRecord::Migration
  def change
    change_column :tickers, :last, :decimal, :scale => 8, :precision => 16
  end
end