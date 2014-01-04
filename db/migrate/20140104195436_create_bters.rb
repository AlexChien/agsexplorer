class CreateBters < ActiveRecord::Migration
  def change
    create_table :bters do |t|
      t.string :pair
      t.decimal :last, :scale => 2, :precision => 8

      t.timestamps
    end

    add_index :bters, :pair
    add_index :bters, :created_at
  end
end