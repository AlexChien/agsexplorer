class AddTokenToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :token, :string

    add_index :notifications, :token

    # update legacy records
    Notification.where(token: nil).each do |notifier|
      notifier.generate_token; notifier.save
    end
  end
end