class CreateMusicDonations < ActiveRecord::Migration
  def change
    create_table "music_donations", :force => true do |t|
      t.integer   "block_height",                                             :null => false
      t.timestamp "time",                 :limit => 6,                        :null => false
      t.string    "address",                                                  :null => false
      t.integer   "amount",               :limit => 8,                        :null => false
      t.string    "network",                           :default => "bitcoin"
      t.integer   "rate",                 :limit => 8
      t.integer   "total",                :limit => 8
      t.integer   "ags_amount",           :limit => 8, :default => 0
      t.integer   "today_total_donation", :limit => 8, :default => 0
      t.integer   "today_price",          :limit => 8, :default => 0
      t.string    "wallet_id"
      t.string    "txbits"
      t.text      "related_addresses"

      t.timestamps
    end

    add_index "music_donations", ["address"], :name => "index_music_donations_on_address"
    add_index "music_donations", ["block_height"], :name => "index_music_donations_on_block_height"
    add_index "music_donations", ["network"], :name => "index_music_donations_on_network"
    add_index "music_donations", ["rate"], :name => "index_music_donations_on_rate"
    add_index "music_donations", ["time"], :name => "index_music_donations_on_time"
    add_index "music_donations", ["total"], :name => "index_music_donations_on_total"
    add_index "music_donations", ["wallet_id"], :name => "index_music_donations_on_wallet_id"

  end
end
