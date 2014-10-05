class CreateMusicDailies < ActiveRecord::Migration
  def change
    create_table :music_dailies, :force => true do |t|
      t.string    "network",                 :default => "btc"
      t.date      "date"
      t.integer   "price",      :limit => 8
      t.integer   "amount",     :limit => 8

      t.timestamps
    end

    add_index "music_dailies", ["date"], :name => "index_music_dailies_on_date"
    add_index "music_dailies", ["network"], :name => "index_music_dailies_on_network"
  end
end
