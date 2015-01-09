class CreatePlayDailies < ActiveRecord::Migration
  def change
    create_table :play_dailies, :force => true do |t|
      t.string    "network",                 :default => "btc"
      t.date      "date"
      t.integer   "price",      :limit => 8
      t.integer   "amount",     :limit => 8

      t.timestamps
    end

    add_index "play_dailies", ["date"], :name => "index_play_dailies_on_date"
    add_index "play_dailies", ["network"], :name => "index_play_dailies_on_network"

  end
end
