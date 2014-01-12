class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :email

      t.timestamps
    end

    add_index :notifications, :email
  end
end