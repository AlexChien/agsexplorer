class CreateDacGeneses < ActiveRecord::Migration
  def change
    create_table :dac_geneses do |t|
      t.string :dac
      t.string :address
      t.integer :amount, :limit => 8

      t.timestamps
    end

    add_index :dac_geneses, [:dac, :address]
  end
end